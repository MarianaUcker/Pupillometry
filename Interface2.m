
function varargout = Interface2(varargin) 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',   	mfilename, ...
               	'gui_Singleton',  gui_Singleton, ...
    	           'gui_OpeningFcn', @Interface2_OpeningFcn, ...
               	'gui_OutputFcn',  @Interface2_OutputFcn, ...
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
 
 
% --- Executes just before Interface2 is made visible.
function Interface2_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Interface2_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
p = imread('pupilometria.png');
imshow(p)

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)

% Extrai o valore fornecido na interface  
limiar = get(handles.edit7, 'string')
pname = uigetdir(pwd,'Selecione o diretório que contém as imagens');
eye_file = sprintf('%s\\Eye\\Eye_', pname);
last_frame = get_first_or_last_frame_num(sprintf('%s\\Eye\\', pname), 'Eye_', 5, 'last') % número total de frames
dname = strcat(pname, '\Eye');
%Cria o arquivo onde serão salvos os resultados da medição
fid = fopen(strcat(dname,'\Resultado_diâmetro.txt'),'w')
%faz a medição do diâmetro do primeiro frame até o último frame
 for i=1:last_frame
     area = 0;
     I = imread(strcat(dname,sprintf('\\Eye_%.5d.jpg',i)));

     I3 = rgb2gray(I); % escala de cinza
     I1= I3(70:300,320:600);
     fr = medfilt2(I1,[27 27]);
     limiar1 = str2num(limiar);
     d = fr >= limiar1;
     c= d*255; % O Matlab entende que “c” é uma matriz tridimensional (Altura, Largura e RGB)
     %  imshow(c)
     threshold = graythresh(c); 
     bw = im2bw(c,threshold);  % preto e branco puro
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
  if area0>area && area0<30000
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
         if boundary(i,2) > Pmaior
            Pmaior = boundary(i,2);
         end;
         if boundary(i,2) < Pmenor
            Pmenor = boundary(i,2);
        end;
     end;
     diametrototal = Pmaior-Pmenor;
%      x = lx(i);
%      diametrolux = ;
%      diametro = diametrototal - diametrolux;
     fprintf(fid,'%12.8f\n',diametrototal);
 end;
 
fclose(fid);

arquivo = fopen(strcat(dname,'\Resultado_diâmetro.txt'),'r');
v = fscanf(arquivo,'%f')
t=1:1:(last_frame);
% m1 = 0; m2 =0; m3 = 0; m4 = 0; m5 = 0; m6 = 0; m7 = 0; m8 = 0; m9 = 0; m10 = 0;
% m11 = 0; m12 =0; m13 = 0; m14 = 0; m15 = 0; m16 = 0; m17 = 0; m18 = 0; m19 = 0; m20 = 0;
% m21 =0; m22 =0; m23 =0; m24=0;
% for i=1:20
%     m1 = m1+v(i);
% end
% for i=20:40
%     m2 = m2+v(i);
% end
% for i=40:60
%     m3 = m3+v(i);
% end
% for i=60:80
%     m4 = m4+v(i);
% end
% for i=80:100
%     m5 = m5+v(i);
% end
% for i=100:120
%     m6 = m6+v(i);
% end
% for i=120:140
%     m7 = m7+v(i);
% end
% for i=140:160
%     m8 = m8+v(i);
% end
% for i=160:180
%     m9 = m9+v(i);
% end
% for i=180:200
%     m10 = m10+v(i);
% end
% 
% 
% 
% for i=200:220
%     m11 = m11+v(i);
% end
% for i=220:240
%     m12 = m12+v(i);
% end
% for i=240:260
%     m13 = m13+v(i);
% end
% for i=260:280
%     m14 = m14+v(i);
% end
% for i=280:300
%     m15 = m15+v(i);
% end
% for i=300:320
%     m16 = m16+v(i);
% end
% for i=320:340
%     m17 = m17+v(i);
% end
% for i=340:360
%     m18 = m18+v(i);
% end
% for i=360:380
%     m19 = m19+v(i);
% end
% for i=380:400
%     m20 = m20+v(i);
% end
% 
% for i=400:420
%     m21 = m21+v(i);
% end
% 
% for i=420:440
%     m22 = m22+v(i);
% end
% 
% for i=440:460
%     m23 = m23+v(i);
% end
% 
% for i=460:480
%     m24 = m24+v(i);
% end
% 
% 
% 
% for i=1:20
%    v(i) = m1/20;
% end
% for i=20:40
%     v(i) = m2/20;
% end
% for i=40:60
%     v(i) = m3/20;
% end
% for i=60:80
%     v(i) = m4/20;
% end
% for i=80:100
%     v(i) = m5/20;
% end
% for i=100:120
%     v(i) = m6/20;
% end
% for i=120:140
%     v(i) = m7/20;
% end
% for i=140:160
%     v(i) = m8/20;
% end
% for i=160:180
%    v(i) = m9/20;
% end
% for i=180:200
%    v(i) = m10/20;
% end
% 
% 
% 
% for i=200:220
%     v(i) = m11/20;
% end
% for i=220:240
%     v(i) = m12/20;
% end
% for i=240:260
%     v(i) = m13/20;
% end
% for i=260:280
%     v(i) = m14/20;
% end
% for i=280:300
%     v(i) = m15/20;
% end
% for i=300:320
%     v(i) = m16/20;
% end
% for i=320:340
%    v(i) = m17/20;
% end
% for i=340:360
%     v(i) = m18/20;
% end
% for i=360:380
%     v(i) = m19/20;
% end
% for i=380:400
%     v(i) = m20/20;
% end
% for i=400:420
%     v(i) = m21/20;
% end
% 
% for i=420:440
%     v(i) = m22/20;
% end
% 
% for i=440:460
%     v(i) = m23/20;
% end
% 
% for i=460:480
%     v(i) = m24/20;
% end

figure(2)
plot(t,v);
xlabel('Tempo (quadros)');
ylabel('Diâmetro (Pixels)');
title('Variação do Diâmetro da Pupila');

% m=0; d=0;
% for i=1:1:last_frame
%     m= m+v(i,1);
% end;
% 
% media = double (m./(last_frame-1))
% 
% for i=2:last_frame
%     d= d + double((v(i,1) - media)^2);
% end
% 
% k= double(d./(last_frame-2));
% desvio_padrao= double(sqrt(k));

 
function pushbutton15_Callback(hObject, eventdata, handles)
cont= 0;
dname = uigetdir % seleciona o diretório onde será criada a pasta
eval(sprintf('!mkdir %s\\Eye', dname)); % cria a pasta 
dname1 = strcat(dname, '\Eye');  % diretorio da pasta criada
fid = fopen(strcat(dname,'\Luminosidade.txt'),'w'); %cria um arquivo de escrita na pasta criada
mycam = webcam(2);
a = arduino();
pause()
for i=1:700
    tic;
  img = snapshot(mycam);
  imwrite(img, (strcat(dname1,sprintf('\\Eye_%.5d.jpg',i)))); %salva as imagens na pasta criada
  x = readVoltage(a, 'A4'); % Lê o valor presente na entrada analógica 1 do Arduino

  % 100 - 200
if (x>=0.72 && x<1.35)
y = -158.73*x + 314.29;

% 600 2000
elseif (x>=0.14 && x<0.31)
y = -2.4391e+05*x^3 + 2.0919e+05*x^2 + -63581*x + 7470.1;

% 200 600
elseif (x>=0.31 && x<0.72)
y = -4673.1*x^3 + 9536.3*x^2 -6885.5*x + 1958.3; 

%10 - 100
elseif (x>=1.35 && x<=4.5)
y = -4.79*x^3 + 44.425*x^2 -152.25*x + 232.22 ;
else
    y = 0;
 end
fprintf(fid,'%12.8f\r\n',y);


% if (cont == 40)
% writeDigitalPin(a,'D2', 1); 
% writeDigitalPin(a,'D3', 1); 
% writeDigitalPin(a,'D4', 1); 
% writeDigitalPin(a,'D5', 1); 
% writeDigitalPin(a,'D6', 1); 
% end
% 
% if (cont == 100)
% writeDigitalPin(a,'D2', 0); 
% writeDigitalPin(a,'D3', 0); 
% writeDigitalPin(a,'D4', 0); 
% writeDigitalPin(a,'D5', 0); 
% writeDigitalPin(a,'D6', 0); 
% end
% 
% 
% if (cont == 200)
% writeDigitalPin(a,'D2', 1); 
% writeDigitalPin(a,'D3', 1); 
% writeDigitalPin(a,'D4', 1); 
% writeDigitalPin(a,'D5', 1); 
% writeDigitalPin(a,'D6', 1); 
% end


% if (cont == 20)
% writeDigitalPin(a,'D2', 1); 
% end
% if (cont == 40)
% writeDigitalPin(a,'D3', 1);
% end
% if (cont == 60)
% writeDigitalPin(a,'D4', 1);
% end
% if (cont == 80)
% writeDigitalPin(a,'D5', 1);
% end
% if (cont == 100)
% writeDigitalPin(a,'D6', 1);
% end
% if (cont == 120)
% writeDigitalPin(a,'D7', 1);
% end
% if (cont == 140)
% writeDigitalPin(a,'D8', 1);
% end
% if (cont == 160)
% writeDigitalPin(a,'D9', 1);
% end
% if (cont == 180)
% writeDigitalPin(a,'D10', 1);
% end
% if (cont == 200)
% writeDigitalPin(a,'D11', 1);
% end
% if (cont == 220)
% writeDigitalPin(a,'D2', 0); 
% end
% if (cont == 240)
% writeDigitalPin(a,'D3', 0);
% end
% if (cont == 260)
% writeDigitalPin(a,'D4', 0);
% end
% if (cont == 280)
% writeDigitalPin(a,'D5', 0);
% end
% if (cont == 300)
% writeDigitalPin(a,'D6', 0);
% end
% if (cont == 320)
% writeDigitalPin(a,'D7', 0);
% end
% if (cont == 340)
% writeDigitalPin(a,'D8', 0);
% end
% if (cont == 360)
% writeDigitalPin(a,'D9', 0);
% end
% if (cont == 380)
% writeDigitalPin(a,'D10', 0);
% end
% if (cont == 400)
% writeDigitalPin(a,'D11', 0);
% end
tac(i) = toc;
 end;
figure (5)
plot(tac);
fclose(fid);
 
%Funções para Interface

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function dataaquisition(hObject, eventdata, handles)

function edit6_Callback(hObject, eventdata, handles)

function edit6_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
pname = uigetdir(pwd,'Selecione o diretório que contém as imagens');
dname = strcat(pname, '\Eye');
I = imread(strcat(dname,sprintf('\\Eye_%.5d.jpg',1)));
I3 = rgb2gray(I);
imtool(I3)



function edit10_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit11_Callback(hObject, eventdata, handles)

function edit12_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
