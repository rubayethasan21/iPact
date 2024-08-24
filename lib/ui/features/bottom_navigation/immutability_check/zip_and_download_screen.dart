import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

class ZipAndDownloadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? _zipFilePath;
    bool _isLoading = false;
    String _statusMessage = '';
    double _progress = 0;

    Future<void> _zipAndSaveDirectory(StateSetter setState) async {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Zipping files...';
        _progress = 0;
      });

      try {
        // Define the path to the target directory (de.ipact.ipact_hhn)
        final appDir = Directory('/data/data/de.ipact.ipact_hnn');

        if (!appDir.existsSync()) {
          throw Exception('Directory does not exist: ${appDir.path}');
        }

        // Create an archive
        final archive = Archive();

        // Add files from the directory to the archive
        final files = appDir.listSync(recursive: true);
        int totalFiles = files.length;
        int processedFiles = 0;

        for (var file in files) {
          if (file is File) {
            final fileBytes = file.readAsBytesSync();
            final relativePath = file.path.replaceFirst(appDir.path, '');
            archive.addFile(ArchiveFile(relativePath, fileBytes.length, fileBytes));

            processedFiles++;
            setState(() {
              _progress = processedFiles / totalFiles;
            });
          }
        }

        // Encode the archive to a ZIP file
        final zipEncoder = ZipEncoder();
        final zipData = zipEncoder.encode(archive);

        if (zipData == null) throw Exception('Failed to encode ZIP data.');

        // Save the ZIP file inside the de.ipact.ipact_hhn directory
        final zipFilePath = p.join(appDir.path, 'app_data.zip');
        final zipFile = File(zipFilePath);

        // Write the ZIP file to the specified directory
        await zipFile.writeAsBytes(zipData);

        setState(() {
          _zipFilePath = zipFilePath;
          _isLoading = false;
          _statusMessage = 'ZIP file created successfully!';
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error: ${e.toString()}';
        });
      }
    }

    Future<void> _downloadZipFileInDevice(StateSetter setState) async {
      if (_zipFilePath != null) {
        String? outputFile = await FilePicker.platform.getDirectoryPath();

        if (outputFile != null) {
          try {
            final fileName = p.basename(_zipFilePath!);
            final newFilePath = p.join(outputFile, fileName);
            final newFile = File(newFilePath);

            // Copy the ZIP file to the selected directory
            await File(_zipFilePath!).copy(newFilePath);

            setState(() {
              _statusMessage = 'ZIP file downloaded successfully to $newFilePath!';
            });
          } catch (e) {
            setState(() {
              _statusMessage = 'Error downloading ZIP file: ${e.toString()}';
            });
          }
        } else {
          setState(() {
            _statusMessage = 'Download cancelled';
          });
        }
      }
    }

    void _shareZipFile() {
      if (_zipFilePath != null) {
        Share.shareFiles([_zipFilePath!], text: 'Here is your zipped data file.');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Download Data as ZIP'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    Column(
                      children: [
                        LinearProgressIndicator(value: _progress),
                        SizedBox(height: 20),
                        Text(
                          (_progress * 100).toStringAsFixed(0) + '%',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  if (!_isLoading && _statusMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _statusMessage.contains('Error')
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.archive),
                    label: Text('Create ZIP File'),
                    onPressed: () async {
                      _zipAndSaveDirectory(setState);
                    },
                  ),
                  if (_zipFilePath != null) ...[
                    SizedBox(height: 20),
                    Text('ZIP file created at:'),
                    SizedBox(height: 5),
                    SelectableText(
                      _zipFilePath!,
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.share),
                      label: Text('Share ZIP File'),
                      onPressed: _shareZipFile,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.download),
                      label: Text('Download ZIP File in Device'),
                      onPressed: () async {
                        _downloadZipFileInDevice(setState);
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
