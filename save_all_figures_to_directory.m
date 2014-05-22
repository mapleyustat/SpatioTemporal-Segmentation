function save_all_figures_to_directory(dir_name)
figlist=findobj('type','figure');
% for i=1:2:numel(figlist)-1
%     saveas(figlist(i),fullfile(dir_name,['frame_pp' num2str(figlist(i)) '.fig']));
%     saveas(figlist(i+1),fullfile(dir_name,['frame' num2str(figlist(i+1)) '.fig']));
% end
for i=1:2:numel(figlist)
    saveas(figlist(i+1),fullfile(dir_name,['frame' num2str(figlist(i)) '.fig']));
end
end