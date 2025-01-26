// import 'dart:io';


// class LogRemoval {
//   final String directoryPath;


//   Result run() {
//     // Validate directory path
//     if (!PathUtils.isValidDirectory(directoryPath)) {
//       return Result(success: false, message: 'Invalid directory.');
//     }

//     final files = FileHandler.getDartFiles(Directory(directoryPath));


//     return Result(
//       success: true,
//       message: 'Log removal completed.',
//       filesProcessed: cleanedFiles.length,
//     );
//   }
// }