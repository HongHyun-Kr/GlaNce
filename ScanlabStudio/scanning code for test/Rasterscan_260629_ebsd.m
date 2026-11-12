clc;
clear;

%group number vector setting
%change!
RR = 50; %repetition rate [kHz]

%change!
s = ['R','R','R','R','R','R','R','R','R']; %scan direction (select 'U'(up), 'D'(down), 'R'(right), 'L'(left))
%change!
l = ['D','D','D','D','D','D','D','D','D']; %line direction (select 'U'(up), 'D'(down), 'R'(right), 'L'(left))
%change!
ds = [10.253 7.25 5.920 10.253 7.25 5.920 10.253 7.25 5.920]; %scan pitch [um] - 바꿈 (Threshold energy: 70 , um)

%change!
dl = [10.253 7.25 5.920 10.253 7.25 5.920 10.253 7.25 5.920]; %line pitch [um] - 바꿈

GN = length(dl);

SS = RR * ds / 1000; %scan speed [m/s] 
JS = SS; %jump speed [m/s]

%change!
PW = [6,6,6,6,6,6,6,6,6]; %polygon width(X) [mm]
%change!
PH = [6,6,6,6,6,6,6,6,6]; %polygon height(Y) [mm]
%change!
E = (PH*1000)./dl;

E = round( ( PH * 1000 ) ./ dl );
F = rem(E,2);
[aa, bb] = find(F == 0);
E(bb) = E(bb) - 1;

LN = [E]; %line total number [#] - ph/dl
PN = LN * 2; %point total number [#]

%change!
R = 0; %rotation angle

%change!
GTX = [-3.5,3,9.5,-3.5,3,9.5,-3.5,3,9.5]; %upper right point (X axis)
%change!
GTY = [9.5,9.5,9.5,3,3,3,-3.5,-3.5,-3.5]; %upper right point (Y axis)

%change!
Xtran = [0,0,0,0,0,0,0,0,0]; %group translation X [mm] typical '0'
%change!
Ytran = [0,0,0,0,0,0,0,0,0]; %group translation Y [mm] typical '0'

%change!
IDs = 'Rasterscan_260629_ebsd'; % basic file name
ID2 = '.txt';

ID = [IDs ID2];
fileID = fopen(ID,'a');

NN = GN; %polygon UID number

et = zeros(1,GN);
GW = zeros(1,GN);
GH = zeros(1,GN);
GCX = zeros(1,GN);
GCY = zeros(1,GN);
PCX = zeros(1,GN);
PCY = zeros(1,GN);
FPX = zeros(1,GN);
FPY = zeros(1,GN);

for g = 1:GN
    N = g; %group UID number
    
    S = s(g);
    L = l(g);
    
    switch S
        case 'U'
            PW(g) = (LN(g) - 1) * dl(g) / 1000;
            dd1 = PW(g);
            dd2 = PH(g);
        case 'D'
            PW(g) = (LN(g) - 1) * dl(g) / 1000;
            dd1 = PW(g);
            dd2 = PH(g);
        case 'R'
            PH(g) = (LN(g) - 1) * dl(g) / 1000;
            dd1 = PH(g);
            dd2 = PW(g);
        case 'L'
            PH(g) = (LN(g) - 1) * dl(g) / 1000;
            dd1 = PH(g);
            dd2 = PW(g);
    end
    
    GW(g) = PW(g); %group width [mm]
    GH(g) = PH(g); %group height [mm]
    
    GCX(g) = GTX(g) - GW(g)/2; %group center X [mm]
    GCY(g) = GTY(g) - GH(g)/2; %group center Y [mm]
    
    PCX(g) = GCX(g); %polygon center X
    PCY(g) = GCY(g); %polygon center Y
    
    run group_setting
    
    XX = [GTX(g) - GW(g), GTX(g)]; %X position list
    YY = [GTY(g) - GH(g), GTY(g)]; %Y position list
    
    switch S
        case 'U'
            switch L
                case 'R'
                    FPX(g) = XX(1); %first point position X [mm]
                    FPY(g) = YY(1); %first point position Y [mm]
                    d = dl(g) / 1000;
                case 'L'
                    FPX(g) = XX(2);
                    FPY(g) = YY(1);
                    d = -dl(g) / 1000;
            end
            PXX = PCX(g);
            PYY = FPY(g);
        case 'D'
            switch L
                case 'R'
                    FPX(g) = XX(1);
                    FPY(g) = YY(2);
                    d = dl(g) / 1000;
                case 'L'
                    FPX(g) = XX(2);
                    FPY(g) = YY(2);
                    d = -dl(g) / 1000;
            end
            PXX = PCX(g);
            PYY = FPY(g);
        case 'R'
            switch L
                case 'U'
                    FPX(g) = XX(1);
                    FPY(g) = YY(1);
                    d = dl(g) / 1000;
                case 'D'
                    FPX(g) = XX(1);
                    FPY(g) = YY(2);
                    d = -dl(g) / 1000;
            end
            PXX = FPX(g);
            PYY = PCY(g);
        case 'L'
            switch L
                case 'U'
                    FPX(g) = XX(2);
                    FPY(g) = YY(1);
                    d = dl(g) / 1000;
                case 'D'
                    FPX(g) = XX(2);
                    FPY(g) = YY(2);
                    d = -dl(g) / 1000;
            end
            PXX = FPX(g);
            PYY = PCY(g);
    end
            
    NN = NN + 1;
    PX = FPX(g);
    PY = FPY(g);
    
    run polygon_setting
    
    fprintf(fileID,'        </ChildElements>\n');
    fprintf(fileID,'      </GroupElement>\n');
    
    et(g) = ((dd2 * LN(g)) + dd1) / (1000 * SS(g)); %expecting time [s]
    fprintf('Group %g expecting time: %g s \n',g,et(g));

end

fprintf(fileID,'    </ChildElements>\n');
fprintf(fileID,'  </JobElement>\n');
fprintf(fileID,'</ModelData>\n');

fclose(fileID);

fprintf('total expecting time: %g s \n',sum(et));