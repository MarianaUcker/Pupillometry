

function varargout = Interface1(varargin)
 
% INTERFACE1 MATLAB code for Interface1.fig
%  	INTERFACE1, by itself, creates a new INTERFACE1 or raises the existing
%  	singleton*.
%
%  	H = INTERFACE1 returns the handle to a new INTERFACE1 or the handle to
%  	the existing singleton*.
%
%      INTERFACE1('CALLBACK',hObject,eventData,handles,...) calls the local
%  	function named CALLBACK in INTERFACE1.M with the given input arguments.
%
%  	INTERFACE1('Property','Value',...) creates a new INTERFACE1 or raises the
%  	existing singleton*.  Starting from the left, property value pairs are
%  	applied to the GUI before Interface1_OpeningFcn gets called.  An
%  	unrecognized property name or invalid value makes property application
%  	stop.  All inputs are passed to Interface1_OpeningFcn via varargin.
%
%  	*See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  	instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help Interface1
 
% Last Modified by GUIDE v2.5 24-Nov-2018 14:58:51
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',   	mfilename, ...
               	'gui_Singleton',  gui_Singleton, ...
    	           'gui_OpeningFcn', @Interface1_OpeningFcn, ...
               	'gui_OutputFcn',  @Interface1_OutputFcn, ...
               	'gui_LayoutFcn',  [] , ...
               	'gui_Callback',   []);
if nargin && ischar(varargin{1})
	gui_State.gui_Callback = str2func(varargin{1});
end
 
if nargout
	[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
	gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
 
 
% --- Executes just before Interface1 is made visible.
function Interface1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject	handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles	structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Interface1 (see VARARGIN)
 
% Choose default command line output for Interface1
handles.output = hObject;
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes Interface1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = Interface1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject	handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles	structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
p = imread('pupilometria.png');
imshow(p)
 
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
[sfname, spname] = uigetfile('*.mp4','Scene Image');
sf = strcat(spname, sfname);
 
[efname, epname] = uigetfile('*.mp4','Eye Image', spname);
ef = strcat(epname, efname);
 
eval(sprintf('!mkdir %s\\Scene', spname));
eval(sprintf('!mkdir %s\\Eye', epname));
eval(sprintf('!ffmpeg -i %s  %sScene\\Scene_%%5d.jpg', sf, spname));
eval(sprintf('!ffmpeg -i %s  %sEye\\Eye_%%5d.jpg', ef, epname));
 
 
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
pname = uigetdir(pwd,'Select Dir to save calibration data');
eye_file = sprintf('%s\\Eye\\Eye_', pname);
scene_file = sprintf('%s\\Scene\\Scene_', pname);
calibration_data_name = sprintf('%s\\calibration.mat', pname);
calibration_image_name = sprintf('%s\\calibration.png', pname);
 
beta = 0.2;     	% the parameter for noise reduction
frame_step = 5; 	% the frame step for browsing
 
% Automatically get the frame number range
first_frame = get_first_or_last_frame_num(sprintf('%s\\Eye\\', pname), 'Eye_', 5, 'first')
last_frame = get_first_or_last_frame_num(sprintf('%s\\Eye\\', pname), 'Eye_', 5, 'last')
frame_index = first_frame+5;
 
Ie5 = read_gray_image(eye_file, frame_index-5);
Ie4 = read_gray_image(eye_file, frame_index-4);
Ie3 = read_gray_image(eye_file, frame_index-3);
Ie2 = read_gray_image(eye_file, frame_index-2);
Ie1 = read_gray_image(eye_file, frame_index-1);
normalize_factor = (sum(Ie5,2) + sum(Ie4,2) + sum(Ie3,2) + sum(Ie2,2) + sum(Ie1,2))/(5*size(Ie1,2));
Ie = read_gray_image(eye_file, frame_index);
[Ie, normalize_factor] = reduce_noise_temporal_shift(Ie, normalize_factor, beta);
 
Is = read_image(scene_file, frame_index);
handle = figure, subplot(1,2,1); imshow(uint8(Is));
title({'Instruction:'; sprintf('left button=next %d frame', frame_step); ...
   	sprintf('right button=previous %d frame', frame_step); 'middle button=indicate calibration point in scene';});
 
subplot(1,2,2); imshow(uint8(Ie));
title(sprintf('frame %d (last frame:%d)', frame_index, last_frame));
 
fprintf(1,'Instruction:\n left button=next frame\n middle button=select calibration point\n right button=previous frame\n');
 
left_button=1;
middle_button=2;
right_button=3;
 
cal_frame = zeros(9,1);
cal_scene = zeros(9,2);
cal_cr = zeros(9,3);
cal_ellipse = zeros(9,5);
cal_index = 1;
browse_or_auto_next = 1;	% indicator: 1-use mouse click to browse images; 0-auto browse next frame
while cal_index <= 9,
	if browse_or_auto_next == 1
    	[x, y, button] = ginput(1);
	else
    	button = left_button;
    	browse_or_auto_next = 1;
	end
	if button == middle_button
    	cal_frame(cal_index) = frame_index;
  	  cal_scene(cal_index, 1) = x;
    	cal_scene(cal_index, 2) = y;
    	hold on;
    	plot(x, y, 'g+');
    	
    	title({'Instruction:'; 'Please click near pupil center in the eye image'});
    	[cx, cy] = ginput(1);
    	[cal_ellipse(cal_index,:), cal_cr(cal_index,:)] = detect_pupil_and_corneal_reflection(Ie, cx, cy, 20);
    	if uint16(cal_ellipse(cal_index,1)) <= 0 || uint16(cal_ellipse(cal_index, 2)) <= 0
        	title({'ERROR! Ellipse parameter:';
               	sprintf('major-minor axis(%4.1f,%4.1f); center(%4.1f,%4.1f); angle(%4.1f)', ...
               	cal_ellipse(cal_index,1), cal_ellipse(cal_index,2), cal_ellipse(cal_index,3), cal_ellipse(cal_index,4), cal_ellipse(cal_index,5))});
    	else
        	title(sprintf('Instruction:\n Left button=ellipse is correct\n Other wise=ellipse is wrong, selete another frame'));
        	plot(cal_ellipse(:,3), cal_ellipse(:,4), 'g+');
        	plot(cal_cr(:,1), cal_cr(:,2), 'b+');
        	[x, y, button] = ginput(1);  	
        	if button == 1
            	cal_index = cal_index+1;
        	else
            	cal_scene(cal_index,:) = zeros(1,2);
            	cal_cr(cal_index,:) = zeros(1,3);
            	cal_ellipse(cal_index,:) = zeros(1,5);
	        end
        	browse_or_auto_next = 0;
    	end
	else
    	Is = [];
    	Ie = [];
    	if button == left_button
        	if frame_index+frame_step > last_frame
            	fprintf('ERROR! frame index exceed (%d-%d)\n', first_frame, last_frame);
            	title(sprintf('ERROR! frame index exceed (%d-%d)', first_frame, last_frame));
            	continue;
        	end
        	frame_index = frame_index+frame_step;
    	else
        	if frame_index-frame_step < first_frame
            	fprintf('ERROR! frame index exceed (%d-%d)\n', first_frame, last_frame);
            	title(sprintf('ERROR! frame index exceed (%d-%d)', first_frame, last_frame));
            	continue;
        	end
        	frame_index = frame_index-frame_step;
    	end;
    	
    	Ie = read_gray_image(eye_file, frame_index);
    	[Ie, normalize_factor] = reduce_noise_temporal_shift(Ie, normalize_factor, beta);
    	Is = read_image(scene_file, frame_index);
  	  
    	subplot(1,2,2); imshow(uint8(Ie)); hold on;
    	if cal_index > 1
        	plot(cal_ellipse(:,3), cal_ellipse(:,4), 'g+');
        	plot(cal_cr(:,1), cal_cr(:,2), 'b+');
    	end
    	title(sprintf('frame %d (last frame:%d)', frame_index, last_frame));
    	
    	subplot(1,2,1); imshow(uint8(Is)); hold on;
    	if cal_index > 1
        	plot(cal_scene(:,1), cal_scene(:,2), 'g+');
    	end
    	title({'Instruction:'; sprintf('left button=next %d frame', frame_step); ...
           	sprintf('right button=previous %d frame', frame_step); 'middle button=indicate calibration point in scene';});
 	end;
end
 
save(sprintf('%s', calibration_data_name),'cal_scene', 'cal_ellipse', 'cal_cr', 'cal_frame');
print(handle, '-djpeg', sprintf('%s', calibration_image_name));
 
 
 
 
function [I] = read_gray_image(file, index);
I = double(rgb2gray(imread(sprintf('%s%05d.png', file, index))));
 
function [I] = read_image(file, index);
I = double(imread(sprintf('%s%05d.png', file, index)));
 
 
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
pname = uigetdir(pwd,'Select Dir of data');
scene_file = sprintf('%s\\Scene\\Scene_', pname);
eye_file = sprintf('%s\\Eye\\Eye_', pname);
calibration_data_name = sprintf('%s\\calibration.mat', pname);
ellipse_result_file = sprintf('%s\\ellipse_result.mat', pname);
dat_file = sprintf('%s\\ellipse_result.dat', pname);
pupil_edge_thresh = 20;
max_lost_count = 5; 	% if consecutive lost tracking frame is more than this number, the start point is set to the center of the image
 
% Automatically get the frame number range
first_frame = get_first_or_last_frame_num(sprintf('%s\\Eye\\', pname), 'Eye_', 5, 'first');
last_frame = get_first_or_last_frame_num(sprintf('%s\\Eye\\', pname), 'Eye_', 5, 'last');
start_frame = first_frame+5;
 
% Eliminate the bad calibration points
load(sprintf('%s', calibration_data_name));
bad_cal_indices = [];
Is = read_image(scene_file, cal_frame(end));
Ie = read_gray_image(eye_file, cal_frame(end));
figure,
subplot(1,2,1); imshow(uint8(Is)); hold on;
title({'Scene image:'; 'green cross: preditive gaze location'; 'Eye image:'; 'red cross: pupil center';
   	'blue cross: corneal reflection'; 'yellow star(*): bad calibration correspondence (if any)'});
plot(cal_scene(:,1), cal_scene(:,2), 'g+');
while 1,
	subplot(1,2,2); imshow(uint8(Ie)); hold on;
	title(sprintf(' Instruction:\n left click on the blue cross to eliminate bad \n calibration point correspondence\n when you finish, click other button'));
	plot(cal_ellipse(:,3), cal_ellipse(:,4), 'r+');
	plot(cal_cr(:,1), cal_cr(:,2), 'b+');
	if ~isempty(bad_cal_indices)
    	plot(cal_cr(bad_cal_indices,1), cal_cr(bad_cal_indices,2), 'y*');
	end
	[tx,ty,but] = ginput(1);
	if but == 1,
   	dis = sqrt((cal_cr(:,1)-tx).^2 + (cal_cr(:,2)-ty).^2);
   	min_dis_index = find(dis==min(dis), 1, 'first');
   	bad_cal_indices = [bad_cal_indices min_dis_index];
	else
    	break;
	end
end
bad_cal_indices = [bad_cal_indices 0]; % add a zero in order to eliminate the case of empty set
	
% while 1,
% 	n = input('input the index of bad calibration points obtained by looking at the calibration.png (should be 1-9; 0-end input)\n');
% 	if n >= 1 && n <= 9
%    	bad_cal_indices = [bad_cal_indices n];
% 	elseif n == 0
%     	break;
% 	else
%     	fprintf('Error input! should be 1-9 or 0 to finish\n');
% 	end
% end
 
% % Calculate the homography mapping matrix
% % Use the different vector between pupil center and corneal reflection
% [neye_x, neye_y, T1] = normalize_point_coordinates(cal_ellipse(:,3)-cal_cr(:,1), cal_ellipse(:,4)-cal_cr(:,2));
% [ncal_x, ncal_y, T2] = normalize_point_coordinates(cal_scene(:,1), cal_scene(:,2));
% A = zeros(2*length(ncal_x), 9);
% for i=1:length(ncal_x),
% 	if i ~= bad_cal_indices
%     	A(i*2-1,:) = [0 0 0 -neye_x(i) -neye_y(i) -1 ncal_y(i)*neye_x(i) ncal_y(i)*neye_y(i) ncal_y(i)];
%     	A(i*2,:) = [neye_x(i) neye_y(i) 1 0 0 0 -ncal_x(i)*neye_x(i) -ncal_x(i)*neye_y(i) -ncal_x(i)];
% 	end
% end
% [ua, sa, va] = svd(A);
% c = va(:,end);
% H_cr=reshape(c,[3,3])';
% H_cr=inv(T2)*H_cr*T1
 
% Calculate the second order polynomial parameters for the mapping
% Use the different vector between pupil center and corneal reflection
eye_x = cal_ellipse(:,3)-cal_cr(:,1);
eye_y = cal_ellipse(:,4)-cal_cr(:,2);
cal_x = cal_scene(:,1);
cal_y = cal_scene(:,2);
A = zeros(length(cal_x), 6);
for i=1:length(cal_x),
	if i ~= bad_cal_indices
    	A(i,:) = [eye_y(i)^2 eye_x(i)^2 eye_y(i)*eye_x(i) eye_y(i) eye_x(i) 1];
	end
end
[ua, da, va] = svd(A);
b1 = ua'*cal_x;
b1 = b1(1:6);
par_x = va*(b1./diag(da));
b2 = ua'*cal_y;
b2 = b2(1:6);
par_y = va*(b2./diag(da));
 
frame_index = start_frame;
Ie5 = read_gray_image(eye_file, frame_index-5);
Ie4 = read_gray_image(eye_file, frame_index-4);
Ie3 = read_gray_image(eye_file, frame_index-3);
Ie2 = read_gray_image(eye_file, frame_index-2);
Ie1 = read_gray_image(eye_file, frame_index-1);
normalize_factor = (sum(Ie5,2) + sum(Ie4,2) + sum(Ie3,2) + sum(Ie2,2) + sum(Ie1,2))/(5*size(Ie1,2));
Ie = read_gray_image(eye_file, frame_index);
beta = 0.2;
[Ie, normalize_factor] = reduce_noise_temporal_shift(Ie, normalize_factor, beta);
fig_handle = figure, imshow(uint8(Ie));
title(sprintf('Please click near the pupil center'));
[cx, cy] = ginput(1);
close(fig_handle);
 
[height width] = size(Ie);
scene = zeros(last_frame, 2);
cr = zeros(last_frame, 3);
ellipse = zeros(last_frame, 5);
consecutive_lost_count = 0;
 
tic
for frame_index=start_frame:last_frame
	fprintf(1, '%d-', frame_index);
	if (mod(frame_index,30) == 0)
    	fprintf(1, '\n');
	end
 
	Ie = read_gray_image(eye_file, frame_index);
	[Ie,normalize_factor] = reduce_noise_temporal_shift(Ie, normalize_factor, beta);
	[ellipse(frame_index,:), cr(frame_index,:)] = detect_pupil_and_corneal_reflection(Ie, cx, cy, pupil_edge_thresh);
	
	if ~(ellipse(frame_index,1) <= 0 || ellipse(frame_index, 2) <= 0)
    	consecutive_lost_count = 0;
    	cx = ellipse(frame_index, 3);
    	cy = ellipse(frame_index, 4);
    	
    	% Calbulate the scene position using the different vector of pupil center and corneal reflection
    	evx = cx-cr(frame_index,1);
    	evy = cy-cr(frame_index,2);
    	coef_vector = [evy^2 evx^2 evy*evx evy evx 1];
    	scene(frame_index,:) = [coef_vector*par_x coef_vector*par_y];
    	
    	%scene_pos = H_cr*[cx-cr(frame_index,1) cy-cr(frame_index,2) 1]';
    	%scene(frame_index,:) = [scene_pos(1)\\scene_pos(3) scene_pos(2)\\scene_pos(3)];
	else
    	consecutive_lost_count = consecutive_lost_count + 1;
    	if consecutive_lost_count >= max_lost_count,
        	cx = width/2;
        	cy = height/2;
    	end
	end
end
toc
save(sprintf('%s', ellipse_result_file), 'ellipse', 'cr', 'scene');
save_eye_tracking_data(dat_file, ellipse, cr, scene);
 
 
function [I] = read_gray_image(file, index);
I = double(rgb2gray(imread(sprintf('%s%05d.png', file, index))));
 
function [I] = read_image(file, index);
I = double(imread(sprintf('%s%05d.png', file, index)));
 
 
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
pname = uigetdir(pwd,'Select Dir of data');
eval(sprintf('!mkdir %s\\Result', pname));
eval(sprintf('!mkdir %s\\Result_Eye', pname));
eval(sprintf('!mkdir %s\\Result_Scene', pname));
eval(sprintf('!mkdir %s\\Result_Small_Eye', pname));
eye_file = sprintf('%s\\Eye\\Eye_', pname);
scene_file = sprintf('%s\\Scene\\Scene_', pname);
image_result_file = sprintf('%s\\Result\\result_', pname);
eye_result_file = sprintf('%s\\Result_Eye\\result_', pname);
scene_result_file = sprintf('%s\\Result_Scene\\result_', pname);
small_eye_result_file = sprintf('%s\\Result_Small_Eye\\result_', pname);
ellipse_result_file = sprintf('%s\\ellipse_result.mat', pname);
 
% Automatically get the frame number range
first_frame = get_first_or_last_frame_num(sprintf('%s\\Eye\\', pname), 'Eye_', 5, 'first');
last_frame = get_first_or_last_frame_num(sprintf('%s\\Eye\\', pname), 'Eye_', 5, 'last');
start_frame = first_frame+5;
 
load(ellipse_result_file);
cr = round(cr);
scene = round(scene);
 
cross_len = 15;
cross_len_eye = 11;
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
 
Is = read_image(scene_file, start_frame);
[height width bit] = size(Is);
small_eye_ratio = 0.25;
small_h = uint16(height*small_eye_ratio);
small_w = uint16(width*small_eye_ratio);
Ir = uint8(zeros(size(Is)));
 
tic
for frame_index=1:last_frame
	fprintf(1, '%d-', frame_index);
	if (mod(frame_index,30) == 0)
    	fprintf(1, '\n');
	end
	Is = read_image(scene_file, frame_index);
	Ie = read_image(eye_file, frame_index);	
	
	% The image index must start at least from 4 using ffmpeg to convert
	% jpeg to mpeg
	if frame_index >= start_frame
    	%plot the corneal reflection
    	if cr(frame_index,1) >= cross_len_eye+2 & cr(frame_index,1) <= width-cross_len_eye-1 & ...
            	cr(frame_index,2) >= cross_len_eye+2 & cr(frame_index,2) <= height-cross_len_eye-1
  	      for bit = 1:3
                Ie(cr(frame_index,2),cr(frame_index,1)-cross_len_eye:cr(frame_index,1)+cross_len_eye, bit) = red(bit);
                Ie(cr(frame_index,2)-cross_len_eye:cr(frame_index,2)+cross_len_eye, cr(frame_index,1), bit) = red(bit);
 
                Ie(cr(frame_index,2)+1,cr(frame_index,1)-cross_len_eye:cr(frame_index,1)+cross_len_eye, bit) = red(bit);
                Ie(cr(frame_index,2)-cross_len_eye:cr(frame_index,2)+cross_len_eye, cr(frame_index,1)+1, bit) = red(bit);
 
  	          Ie(cr(frame_index,2)-1,cr(frame_index,1)-cross_len_eye:cr(frame_index,1)+cross_len_eye, bit) = red(bit);
                Ie(cr(frame_index,2)-cross_len_eye:cr(frame_index,2)+cross_len_eye, cr(frame_index,1)-1, bit) = red(bit);
        	end
        end
 
    	% plot the gaze position using the different vector of pupil center and
    	% corneal reflection
    	if scene(frame_index,1) >= cross_len+2 & scene(frame_index,1) <= width-cross_len-1 & ...
            	scene(frame_index,2) >= cross_len+2 & scene(frame_index,2) <= height-cross_len-1
        	for bit = 1:3
                Is(scene(frame_index,2),scene(frame_index,1)-cross_len:scene(frame_index,1)+cross_len,bit) = green(bit);
                Is(scene(frame_index,2)-cross_len:scene(frame_index,2)+cross_len, scene(frame_index,1),bit) = green(bit);
 
                Is(scene(frame_index,2)-1,scene(frame_index,1)-cross_len:scene(frame_index,1)+cross_len,bit) = green(bit);
                Is(scene(frame_index,2)-cross_len:scene(frame_index,2)+cross_len, scene(frame_index,1)-1,bit) = green(bit);
 
                Is(scene(frame_index,2)+1,scene(frame_index,1)-cross_len:scene(frame_index,1)+cross_len,bit) = green(bit);
                Is(scene(frame_index,2)-cross_len:scene(frame_index,2)+cross_len, scene(frame_index,1)+1,bit) = green(bit);
        	end
    	end
 
    	% plot the ellipse
    	if ellipse(frame_index,3) ~= 0 & ellipse(frame_index,4) ~= 0
        	Ie = plot_ellipse_in_image(Ie, ellipse(frame_index,:));
 	       Ie = plot_ellipse_in_image(Ie, [ellipse(frame_index,1) ellipse(frame_index,2) ellipse(frame_index,3)+1 ellipse(frame_index,4)+1 ellipse(frame_index,5)]);
        	Ie = plot_ellipse_in_image(Ie, [ellipse(frame_index,1) ellipse(frame_index,2) ellipse(frame_index,3)-1 ellipse(frame_index,4)+1 ellipse(frame_index,5)]);
        	Ie = plot_ellipse_in_image(Ie, [ellipse(frame_index,1) ellipse(frame_index,2) ellipse(frame_index,3)+1 ellipse(frame_index,4)-1 ellipse(frame_index,5)]);
        	Ie = plot_ellipse_in_image(Ie, [ellipse(frame_index,1) ellipse(frame_index,2) ellipse(frame_index,3)-1 ellipse(frame_index,4)-1 ellipse(frame_index,5)]);
    	end
	end
	imwrite(uint8(Ie), sprintf('%s%05d.png', eye_result_file, frame_index));
	imwrite(uint8(Is), sprintf('%s%05d.png', scene_result_file, frame_index));
	Ie_small = imresize(Ie, small_eye_ratio);
	Is_result = Is;
	Is_result(1:small_h, 1:small_w, :) = Ie_small(1:small_h, 1:small_w, :);
	imwrite(uint8(Is_result), sprintf('%s%05d.png', small_eye_result_file, frame_index));
	
	Ir_tmp = [uint8(imresize(Is,0.5)) uint8(imresize(Ie,0.5))];
    Ir(uint16(height*0.25):uint16(height*0.75)-1, :, :) = Ir_tmp(1:uint16(height*0.5), :, :);
	imwrite(Ir, sprintf('%s%05d.png', image_result_file, frame_index));
end
toc
 
eval(sprintf('!ffmpeg -i %s%%05d.png -b 16000 %s\\eye_result.mpg', eye_result_file, pname));
eval(sprintf('!ffmpeg -i %s%%05d.png -b 16000 %s\\scene_result.mpg', scene_result_file, pname));
eval(sprintf('!ffmpeg -i %s%%05d.png -b 16000 %s\\small_eye_result.mpg', small_eye_result_file, pname));
eval(sprintf('!ffmpeg -i %s%%05d.png -b 16000 %s\\equal_size_result.mpg', image_result_file, pname));
 
 
 
function [I] = read_gray_image(file, index);
I = double(rgb2gray(imread(sprintf('%s%05d.png', file, index))));
 
function [I] = read_image(file, index);
I = double(imread(sprintf('%s%05d.png', file, index)));
 

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
pname = uigetdir(pwd,'Selecione o diretório que contém as imagens');
eye_file = sprintf('%s\\Eye\\Eye_', pname);
last_frame = get_first_or_last_frame_num(sprintf('%s\\Eye\\', pname), 'Eye_', 5, 'last') % número total de frames
dname = uigetdir

fid = fopen(strcat(dname,'\Resultado_diâmetro.txt'),'w')
 for i=1:last_frame
 area = 0;
  I = imread(strcat(dname,sprintf('\\Eye_%.5d.jpg',i)));
 
 limiar = 60;
 d = I >= limiar;
 c= d*255; % O Matlab entende que “c” é uma matriz tridimensional (Altura, Largura e RGB)
%  imshow(c)
I3 = rgb2gray(c); % escala de cinza
threshold = graythresh(I3); 
bw = im2bw(I3,threshold);  % preto e branco puro
% figure(4)
%  imshow(bw)
 [B,L] = bwboundaries(bw);  % Distrubui o colormap Jet pelos objetos
 figure(5)
% imshow(label2rgb(L, @jet, [.5 .5 .5])); % encontrados pela função bwboundaries
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2), boundary(:,1), 'black', 'LineWidth', 2)
end
stats = regionprops(L,'Area');
for k = 1:length(B)
  % A área do contorno k
  area0 = stats(k).Area;
  if area0>area && area0<99999
      %obtem (X,Y) do contorno k
       boundary = B{k};
      area = area0;
        area_string = sprintf('%.0f',area);
        text(boundary(1,2)+5,boundary(1,1)+13,area_string,...
        'Color','white',...
        'FontSize',8,...
        'FontWeight','bold',...
        'BackgroundColor','black',...
        'FontName','Times');
  end
end

hold off
Pmaior = 0;
Pmenor = 50000;
for i=1:length(boundary)
if boundary(i,1) > Pmaior
      Pmaior = boundary(i,1);
  end;
  if boundary(i,1) < Pmenor
      Pmenor = boundary(i,1);
  end;
end;
  diametro = Pmaior-Pmenor;
 a=area;
 set(handles.text7,'string',num2str(a));
        fprintf(fid,'%12.8f \n',diametro);
 end;
 
 fclose(fid);
 arquivo = fopen(strcat(dname,'\Resultado_diâmetro.txt'),'r');
 m=0;
 d=0;
 v = fscanf(arquivo,'%f');
 t =0:1:last_frame;

 plot(t,v);
  xlabel('Tempo (s)');
 ylabel('Área (Pixels)');
 title('Variação da Área da Pupila');
 for i=1:last_frame
 m= m+v(i,1);
 end;
 media = double (m/(last_frame-1))
 for i=2:last_frame
     d= d + double((v(i,1) - media)^2);
 end
 k= double(d/(last_frame-2));%
 desvio_padrao= double(sqrt(k))
 
% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
[sfname, spname] = uigetfile('*.mp4','Scene Image');
sf = strcat(spname, sfname);
 
[efname, epname] = uigetfile('*.mp4','Eye Image', spname);
ef = strcat(epname, efname);
 
eval(sprintf('!mkdir %s\\Scene', spname));
eval(sprintf('!mkdir %s\\Eye', epname));
eval(sprintf('!ffmpeg -i %s  %sScene\\Scene_%%5d.jpg', sf, spname));
eval(sprintf('!ffmpeg -i %s  %sEye\\Eye_%%5d.jpg', ef, epname));
 
 

function edit3_Callback(hObject, ~, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
