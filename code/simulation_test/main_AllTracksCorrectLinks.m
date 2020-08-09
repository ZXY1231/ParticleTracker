
all_gt_ids = AllTracksGTIds(gtmaps_path, all_tracks);
correct_links = TrackingAccuracy(all_gt_ids);
sum(correct_links)