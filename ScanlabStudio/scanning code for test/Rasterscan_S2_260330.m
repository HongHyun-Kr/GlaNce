clc;
clear;

%% Repetition Rate [kHz] (change!)
RR = 50; 

%% Scan & Line direction row setting (change!)
% → Scan direction row (Right → Left 스캔)
GN = 144; % Group Number
s = 'R' * ones(1,GN);

% ↓ Line direction row (Down → Up 스캔)
l = 'D' * ones(1,GN);

%% Scan pitch setting (change!)
% → Scan pitch row
SPx = 2.5000; % cell 내 x pitch [µm]
ds = SPx * ones(1,GN);

% ↓ Line pitch row 1
SPy = 2.5000; % cell 내 y pitch [µm]
dl = SPy * ones(1,GN); 

%% Scan speed calculation
GN = length(dl); % Group Number: 총 cell 수
SS = RR * ds / 1000; % Scan Speed [m/s]: RR(kHz) × ds(µm) → m/s 변환
JS = SS;  % Jump Speed [m/s] (scan speed와 동일하게 세팅)

%% Polygon Width & Height setting (change!)
% ↓ polygon Height(y): 각 cell 세로 길이 [mm]
PH = 1.2 * ones(1,GN);

% → Polygon Width(X): 각 cell 가로 길이 [mm]
PW = 1.2 * ones(1,GN);


%% Line number calculation (LN, PN)
E = (PH*1000)./dl;
E = round( ( PH * 1000 ) ./ dl ); % cell 내 y축 line 개수 (반올림) [µm]
F = rem(E,2); % 짝수 체크
[aa, bb] = find(F == 0); % 짝수인 위치 찾기
E(bb) = E(bb) - 1; % 짝수 → 홀수로 -1 (왜? 홀수 라인 선호)
LN = [E]; % Line Number: 최종 라인 수 배열
PN = LN * 2; % Point Number: 점 수 = 라인 수 × 2 (왕복)


%% Position setting (GTX, GTY) (change!)
R = 0; % rotation angle [degree]

% → Group Top X row: 각 cell의 좌상단 x좌표 [mm]
row_values = [-8.2, -6.6, -5, -3.4, -1.8, -0.2, 1.4, 3, 4.6, 6.2, 7.8, 9.4];
GTX = repmat(row_values, 12, 1);

% ↓ Group Top Y row: 각 cell의 좌상단 y좌표 [mm]
col_values = [9.4:-1.6:-8.2];
GTY = repmat(col_values', 1, 12);

%% Translation setting (Xtran, Ytran) (change!)
% X translation: typically '0'
Xtran = 0 * ones(1,GN);

% Y translation: typically '0'
Ytran = 0 * ones(1,GN);

%% Save Files (change!)
IDs = 'Rasterscan_I0260_N1600_260223'; % ID String: output file name
EXT = '.txt'; % Extension
ID = [IDs EXT];
fileID = fopen(ID,'a'); % 'a': append

NN = GN; % Next Number = Group Number

%% Loop setting
% Zeros: 메모리 할당
ET  = zeros(1,GN);   % Expected Time [s]: 각 영역별 예상 조사시간 배열
GW  = zeros(1,GN);   % Group Width [mm]: 각 영역 실제 너비 배열  
GH  = zeros(1,GN);   % Group Height [mm]: 각 영역 실제 높이 배열
GCX = zeros(1,GN);   % Group Center X [mm]: 각 영역 중심 X좌표 배열
GCY = zeros(1,GN);   % Group Center Y [mm]: 각 영역 중심 Y좌표 배열
PCX = zeros(1,GN);   % Polygon Center X [mm]: 폴리곤 중심 X좌표 배열
PCY = zeros(1,GN);   % Polygon Center Y [mm]: 폴리곤 중심 Y좌표 배열
FPX = zeros(1,GN);   % First Point X [mm]: 각 영역 첫 점 X좌표 배열
FPY = zeros(1,GN);   % First Point Y [mm]: 각 영역 첫 점 Y좌표 배열

% Main loop (for g=1:GN)
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
    
    ET(g) = ((dd2 * LN(g)) + dd1) / (1000 * SS(g)); % Expected Time [s]

end

fprintf(fileID,'    </ChildElements>\n');
fprintf(fileID,'  </JobElement>\n');
fprintf(fileID,'</ModelData>\n');
fclose(fileID);
fprintf('Expecting Time per 1 cell: %.1f 초\n', ET(g)); % 각 cell 시간 출력 
fprintf('Total Expecting Time: %.1f 초 (%.1f 분)\n',sum(ET), sum(ET)/60); % 총 시간 출력 