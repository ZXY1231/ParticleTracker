
t = 100;
dis_error = 2;
p = 8;
tracks_filename_csv = 'Z:\SimulationData\20200805\100f_8p_200pxl\100frames.csv';

all_gt_ids = AllTracksGTIds2(tracks_filename_csv, all_tracks, t, dis_error);
[accuracy,correct_links] = LengthAverageAccuracy2 (tracks_filename_csv, all_gt_ids, t, p);
% correct_links3 = TrackingAccuracy(all_gt_ids);


trackmate_filename_csv = 'Z:\SimulationData\20200805\100f_8p_200pxl\Spots in tracks statistics_2.csv';
all_trackmate_tracks = TrackmateTracks(trackmate_filename_csv);

all_gt_ids2 = AllTracksGTIds2(tracks_filename_csv, all_trackmate_tracks, t, dis_error);
[accuracy2,correct_links2] = LengthAverageAccuracy2 (tracks_filename_csv, all_gt_ids2, t, p);

%%
tracks_table = readtable(tracks_filename_csv);
tracks = table2array(tracks_table);
gt_blinks = tracks(:,3);
gt_blinks = reshape(gt_blinks, [t, p]);

labels = repmat(1:p,[t,1]);

all_gt_ids_test = cell(size(all_gt_ids));
one_map_tracks_ids = zeros(t, size(all_gt_ids,2));

for i = 1:size(all_gt_ids_test,2) 
    all_gt_ids_test{1,i} = all_gt_ids{i};
    one_map_tracks_ids(:,i) = sum(all_gt_ids_test{1,i}.*labels,2);
end
one_gt_ids = all_gt_ids_test{1,1};
for i = 2:size(all_gt_ids_test,2) 
    one_gt_ids = one_gt_ids + all_gt_ids_test{1,i};
end



all_gt_ids2_test = cell(size(all_gt_ids2));
one_map_tracks_ids2 = zeros(t, size(all_gt_ids2,2));
for i = 1:size(all_gt_ids2_test,2) 
    all_gt_ids2_test{1,i} = all_gt_ids2{i};
    one_map_tracks_ids2(:,i) = sum(all_gt_ids2_test{1,i}.*labels,2);
end

one_gt_ids2 = all_gt_ids2_test{1,1};
for i = 2:size(all_gt_ids2_test,2) 
    one_gt_ids2 = one_gt_ids2 + all_gt_ids2_test{1,i};
end

% one_gt_ids2 = one_gt_ids2>0;

% one_gt_ids = one_gt_ids>0;

figure(1)
surf(double(one_gt_ids))
view([0 -90])

figure(2)
surf(double(one_gt_ids2))
view([0 -90])

figure(3)
surf(gt_blinks)
view([0 -90])

% figure(4)
% surf(all_gt_ids_test{1,2})
% view([0 -90])
% 
% figure(5)
% surf(all_gt_ids2_test{1,2})
% view([0 -90])

figure(6)
subplot(3,1,1)
surf(one_map_tracks_ids(:,:))
view([0 -90])
title('Homemade')
xlabel('Tracks')
ylabel('Time')


subplot(3,1,2)
surf(one_map_tracks_ids2(:,:))
view([0 -90])
title('Trackmate')
xlabel('Tracks')
ylabel('Time')

% figure(8)
% surf(one_map_tracks_ids(:,68:71))
% view([0 -90])
% 
% figure(9)
% surf(one_map_tracks_ids2(:,16:19))
% view([0 -90])

leng = min(size(correct_links,2), size(correct_links2,2))
subplot(3,1,3)
sorted_correct_links = sort(correct_links,'descend');
plot(sorted_correct_links(1, 1:leng),'r')
hold on
sorted_correct_links2 = sort(correct_links2,'descend');
plot(sorted_correct_links2(1, 1:leng),'b')
xlabel('tracks')
ylabel('length')
legend(['Homemade' accuracy],['Trackmate'])
title(['                  Tracks length'  '                '  int2str(p) ' Particles  ' int2str(t) ' Frames'])


