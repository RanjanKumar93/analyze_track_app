import 'package:analyze_track/local/local_database.dart';
import 'package:analyze_track/models/track.dart';
import 'package:analyze_track/widgets/chart/chart.dart';
import 'package:analyze_track/widgets/tracks_list/expenses_list.dart';
import 'package:analyze_track/widgets/new_track.dart';
import 'package:flutter/material.dart';

class TrackScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const TrackScreen({super.key, required this.dbHelper});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  List<Track> _registeredTracks = [];

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    final tracks = await widget.dbHelper.getTracks();
    setState(() {
      _registeredTracks = tracks;
    });
  }

  void _openAddTrackOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewTrack(
        onAddTrack: _addTrack,
      ),
    );
  }

  Future<void> _addTrack(Track track) async {
    await widget.dbHelper.insertTrack(track);
    _loadTracks();
  }

  Future<void> _removeTrack(Track track) async {
    final trackIndex = _registeredTracks.indexOf(track);
    setState(() {
      _registeredTracks.remove(track);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Track deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredTracks.insert(trackIndex, track);
            });
            widget.dbHelper.insertTrack(track);
          },
        ),
      ),
    );
    await widget.dbHelper.deleteTrack(track.id);
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
      child: Text('Nothing found. Start adding some!'),
    );

    if (_registeredTracks.isNotEmpty) {
      mainContent = TracksList(
        tracks: _registeredTracks,
        onRemoveTrack: _removeTrack,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Track'),
        actions: [
          IconButton(
            onPressed: _openAddTrackOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ChartScreen(
                    dbHelper: widget.dbHelper,
                  ),
                ),
              );
            },
            child: const Text('Get chart'),
          ),
          Expanded(child: mainContent)
        ],
      ),
    );
  }
}
