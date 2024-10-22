import 'package:analyze_track/models/track.dart';
import 'package:analyze_track/widgets/tracks_list/expense_item.dart';
import 'package:flutter/material.dart';

class TracksList extends StatelessWidget {
  const TracksList({
    super.key,
    required this.tracks,
    required this.onRemoveTrack,
  });

  final List<Track> tracks;
  final void Function(Track track) onRemoveTrack;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        return Dismissible(
            key: ValueKey(tracks[index]),
            background: Container(
              color: Theme.of(context).colorScheme.error.withOpacity(0.75),
              margin: EdgeInsets.symmetric(
                horizontal: Theme.of(context).cardTheme.margin!.horizontal,
              ),
            ),
            onDismissed: (direction) {
              onRemoveTrack(tracks[index]);
            },
            child: TrackItem(tracks[index]));
      },
    );
  }
}
