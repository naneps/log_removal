import * as assert from 'assert';
import * as vscode from 'vscode';
import * as assert from 'assert';
import * as vscode from 'vscode';
import { PRINT_LOG_REGEX, LOG_FUNCTION_REGEX } from '../../extension'; // Import actual regexes

// Helper function to convert string offsets to vscode.Position
function positionAt(text: string, offset: number): vscode.Position {
	let line = 0;
	let character = 0;
	for (let i = 0; i < offset; i++) {
		if (text[i] === '\n') {
			line++;
			character = 0;
		} else {
			character++;
		}
	}
	return new vscode.Position(line, character);
}

// Helper function to get line at a certain offset
function lineAt(text: string, offsetOrLine: number): { text: string, range: vscode.Range, lineNumber: number, rangeIncludingLineBreak: vscode.Range } {
    let lineContent: string;
    let lineNum: number;
    let lineStartOffset: number;
    let lineEndOffset: number;
    let nextLineStartOffset: number | undefined = undefined;

    if (typeof offsetOrLine === 'number' && offsetOrLine >= 0 && offsetOrLine < text.split('\n').length) { // it's a line number
        lineNum = offsetOrLine;
        const lines = text.split('\n');
        lineContent = lines[lineNum];
        lineStartOffset = 0;
        for(let i=0; i < lineNum; i++) {
            lineStartOffset += lines[i].length + 1; // +1 for \n
        }
        lineEndOffset = lineStartOffset + lineContent.length;
        if (lineNum < lines.length - 1) {
            nextLineStartOffset = lineEndOffset + 1; // +1 for \n
        }

    } else if (typeof offsetOrLine === 'number') { // it's an offset
        const lines = text.split('\n');
        let currentOffset = 0;
        let found = false;
        for (let i = 0; i < lines.length; i++) {
            const lineLength = lines[i].length;
            if (offsetOrLine >= currentOffset && offsetOrLine <= currentOffset + lineLength) {
                lineNum = i;
                lineContent = lines[i];
                lineStartOffset = currentOffset;
                lineEndOffset = currentOffset + lineLength;
                if (i < lines.length - 1) {
                    nextLineStartOffset = lineEndOffset + 1;
                }
                found = true;
                break;
            }
            currentOffset += lineLength + 1; // +1 for \n
        }
        if (!found) throw new Error("Offset out of bounds");
    } else {
        throw new Error("Invalid argument for lineAt");
    }


    const startPos = positionAt(text, lineStartOffset);
    const endPos = positionAt(text, lineEndOffset);
    let endIncludingLineBreak = endPos;
    if (nextLineStartOffset !== undefined) {
        endIncludingLineBreak = positionAt(text, nextLineStartOffset);
    }


    return {
        text: lineContent,
        range: new vscode.Range(startPos, endPos),
        lineNumber: lineNum,
        rangeIncludingLineBreak: new vscode.Range(startPos, endIncludingLineBreak)
    };
}


// This function replicates the core logic of finding matches and determining their removal ranges.
// It does not depend on vscode.window.activeTextEditor or other UI elements.
function getTestEdits(documentText: string): vscode.TextEdit[] {
	let edits: vscode.TextEdit[] = [];
	const combinedRegex = new RegExp(
		`(${PRINT_LOG_REGEX.source})|(${LOG_FUNCTION_REGEX.source})`,
		'gm' // Ensure 'g' flag is here, 'm' for multiline ^ $ matching
	);

	let match;
	while ((match = combinedRegex.exec(documentText)) !== null) {
		const matchIndex = match.index;
		const matchText = match[0];
		const startPosition = positionAt(documentText, matchIndex);
		const endPosition = positionAt(documentText, matchIndex + matchText.length);
		let range = new vscode.Range(startPosition, endPosition);

		const line = lineAt(documentText, startPosition.line);

		if (line.text.trim() === matchText.trim()) {
			// If it's the only content, remove the whole line including the line break
            if (startPosition.line < documentText.split('\n').length - 1) {
                 range = new vscode.Range(line.range.start, lineAt(documentText, startPosition.line + 1).range.start);
            } else {
                range = line.range;
            }
		}
		// Else, just the matched range is fine (already set)
		edits.push(vscode.TextEdit.delete(range));
	}
	return edits;
}


suite('Extension Test Suite', () => {
	vscode.window.showInformationMessage('Start all tests.');

	suite('Regular Expression Tests', () => {
		test('PRINT_LOG_REGEX should match valid print statements', () => {
			const validPrints = [
				"print('hello');",
				"  print('hello');  ",
				"print ( 'hello' ) ;",
				"print('hello ${name}');",
				"print(object.toString());",
				"print(1 + 2);",
				"print(\n  'multiline'\n);"
			];
			validPrints.forEach(s => {
				PRINT_LOG_REGEX.lastIndex = 0; // Reset regex state
				assert.ok(PRINT_LOG_REGEX.test(s), `Failed for: ${s}`);
			});
		});

		test('PRINT_LOG_REGEX should not match invalid print statements', () => {
			const invalidPrints = [
				"Print('hello');", // Case-sensitive
				"print 'hello';",   // Missing parentheses
				"print('hello')",   // Missing semicolon
				"// print('hello');", // Commented out
				"myprint('hello');" // Different function name
			];
			invalidPrints.forEach(s => {
				PRINT_LOG_REGEX.lastIndex = 0;
				assert.strictEqual(PRINT_LOG_REGEX.test(s), false, `Incorrectly matched: ${s}`);
			});
		});

		test('LOG_FUNCTION_REGEX should match valid log statements', () => {
			const validLogs = [
				"log('message');",
				"  log('message', level: 900, error: e);  ",
				"log ( 'message' ) ;",
				"log('message ${var}');",
				"log(object.toMap(), name: 'MyObject');",
				"log(\n  'multiline message'\n);"
			];
			validLogs.forEach(s => {
				LOG_FUNCTION_REGEX.lastIndex = 0;
				assert.ok(LOG_FUNCTION_REGEX.test(s), `Failed for: ${s}`);
			});
		});

		test('LOG_FUNCTION_REGEX should not match invalid log statements', () => {
			const invalidLogs = [
				"Log('message');", // Case-sensitive
				"log 'message';",   // Missing parentheses
				"log('message')",   // Missing semicolon
				"// log('message');", // Commented out
				"mylog('message');" // Different function name
			];
			invalidLogs.forEach(s => {
				LOG_FUNCTION_REGEX.lastIndex = 0;
				assert.strictEqual(LOG_FUNCTION_REGEX.test(s), false, `Incorrectly matched: ${s}`);
			});
		});
	});

	suite('TextEdit Generation Logic', () => {
		test('Should generate TextEdit to delete full line for single log statement', () => {
			const docContent = "print('hello');";
			const edits = getTestEdits(docContent);
			assert.strictEqual(edits.length, 1, "Should find one edit");
			const edit = edits[0];
			// Expects deletion from start of line 0 to start of line 1 (or end of doc if last line)
			const expectedRange = new vscode.Range(new vscode.Position(0, 0), new vscode.Position(0, docContent.length));
            // If it's the only line, the range is the line itself. If not, it extends to the start of the next line.
            // Our getTestEdits logic for single/last line: range = line.range;
            // For multiple lines: range = new vscode.Range(line.range.start, lineAt(documentText, startPosition.line + 1).range.start);
            // Since docContent has no newline, it's treated as the "last line" case.
			assert.deepStrictEqual(edit.range, expectedRange, "Range should cover the entire line content");
		});

        test('Should generate TextEdit to delete full line for log statement ending document', () => {
			const docContent = "void main() {}\nprint('hello');";
            const lines = docContent.split('\n');
			const edits = getTestEdits(docContent);
			assert.strictEqual(edits.length, 1, "Should find one edit");
			const edit = edits[0];
            const expectedRange = new vscode.Range(new vscode.Position(1, 0), new vscode.Position(1, lines[1].length));
			assert.deepStrictEqual(edit.range, expectedRange, "Range should cover the entire last line");
		});


		test('Should generate TextEdit to delete full line (including newline) for log statement followed by another line', () => {
			const docContent = "print('hello');\nint x = 5;";
			const edits = getTestEdits(docContent);
			assert.strictEqual(edits.length, 1, "Should find one edit");
			const edit = edits[0];
			// Expects deletion from start of line 0 to start of line 1
			const expectedRange = new vscode.Range(new vscode.Position(0, 0), new vscode.Position(1, 0));
			assert.deepStrictEqual(edit.range, expectedRange, "Range should cover line 0 and its newline");
		});

		test('Should generate TextEdit to delete only statement for log on line with other code (prefix)', () => {
			const docContent = "int x = 5; print('debug');";
			const edits = getTestEdits(docContent);
			assert.strictEqual(edits.length, 1, "Should find one edit");
			const edit = edits[0];
			const expectedRange = new vscode.Range(positionAt(docContent, 12), positionAt(docContent, 12 + "print('debug');".length));
			assert.deepStrictEqual(edit.range, expectedRange, "Range should cover only the print statement");
		});

		test('Should generate TextEdit to delete only statement for log on line with other code (suffix)', () => {
			const docContent = "print('debug'); int x = 5;";
			const edits = getTestEdits(docContent);
			assert.strictEqual(edits.length, 1, "Should find one edit");
			const edit = edits[0];
			const expectedRange = new vscode.Range(positionAt(docContent, 0), positionAt(docContent, "print('debug');".length));
			assert.deepStrictEqual(edit.range, expectedRange, "Range should cover only the print statement");
		});
		
		test('Should generate multiple TextEdits for multiple log lines', () => {
			const docContent = "print('log1');\nint y=0;\nlog('log2');";
            const lines = docContent.split('\n');
			const edits = getTestEdits(docContent);
			assert.strictEqual(edits.length, 2, "Should find two edits");

			const expectedRange1 = new vscode.Range(new vscode.Position(0, 0), new vscode.Position(1, 0)); // Full line for print('log1');
			assert.deepStrictEqual(edits[0].range, expectedRange1, "Range for first log is incorrect");
			
			const expectedRange2 = new vscode.Range(new vscode.Position(2, 0), new vscode.Position(2, lines[2].length));    // Full line for log('log2');
			assert.deepStrictEqual(edits[1].range, expectedRange2, "Range for second log is incorrect");
		});

		test('Should generate no TextEdits for document with no log lines', () => {
			const docContent = "int x = 5;\nString y = 'test';";
			const edits = getTestEdits(docContent);
			assert.strictEqual(edits.length, 0, "Should find no edits");
		});

        test('Should handle log statement with preceding whitespace correctly', () => {
            const docContent = "    print('indented log');\nint x = 0;";
            const edits = getTestEdits(docContent);
            assert.strictEqual(edits.length, 1, "Should find one edit for indented log");
            const expectedRange = new vscode.Range(new vscode.Position(0,0), new vscode.Position(1,0)); // Full line delete
            assert.deepStrictEqual(edits[0].range, expectedRange, "Range for indented log is incorrect");
        });

        test('Should handle log statement with trailing code on the same line', () => {
            const docContent = "print('log here'); var a = 1; // comment";
            const edits = getTestEdits(docContent);
            assert.strictEqual(edits.length, 1);
            const expectedRange = new vscode.Range(positionAt(docContent,0), positionAt(docContent, "print('log here');".length));
            assert.deepStrictEqual(edits[0].range, expectedRange, "Should only remove the log statement part");
        });

	});
});
