%%OM....!!
clc, clear, close all

% Number of faces of polygon
K = 4;                                                                     

% Source Location
s_loc = [2; 2];                                                            

% Dimension
dim = size(s_loc,1);                                                       

% vertices of K faced polygon
p = [0 0;
    9 0;
    9 4;
    0 4]';                                                                

% normals of K-faced polygon
n = [0 -1;
    1 0;
    0 1;
    -1 0]';                                                               

% location of virtual sound sources
sT  =  [s_loc' + 2*((p(:,1) - s_loc)'*n(:,1))*n(:,1)';
    s_loc' + 2*((p(:,2) - s_loc)'*n(:,2))*n(:,2)';
    s_loc' + 2*((p(:,3) - s_loc)'*n(:,3))*n(:,3)';
    s_loc' + 2*((p(:,4) - s_loc)'*n(:,4))*n(:,4)']';

% Euclidean Distance Matrix (EDM) -- this matrix is squared
D = [ 0,                    norm(s_loc - sT(:,1)),      norm(s_loc - sT(:,2)),  norm(s_loc - sT(:,3)),  norm(s_loc - sT(:,4));
    norm(sT(:,1) - s_loc), 0,                          norm(sT(:,1) - sT(:,2)),norm(sT(:,1) - sT(:,3)),norm(sT(:,1) - sT(:,4));
    norm(sT(:,2) - s_loc), norm(sT(:,2) - sT(:,1)),    0,                      norm(sT(:,2) - sT(:,3)),norm(sT(:,2) - sT(:,4));
    norm(sT(:,3) - s_loc), norm(sT(:,3) - sT(:,1)),    norm(sT(:,3) - sT(:,2)),0                      ,norm(sT(:,3) - sT(:,4));
    norm(sT(:,4) - s_loc), norm(sT(:,4) - sT(:,1)),    norm(sT(:,4) - sT(:,2)),norm(sT(:,4) - sT(:,3)),0                     ].^2;

% microphone location
mic_loc = [6 1]';

% room impulse response (RIR)
RIR = zeros(1,6);
RIR(1) = norm(s_loc - mic_loc)^2;
RIR(2) = norm(sT(:,1) - mic_loc)^2;
RIR(3) = norm(sT(:,2) - mic_loc)^2;
RIR(4) = norm(sT(:,3) - mic_loc)^2;
RIR(5) = norm(sT(:,4) - mic_loc)^2;
RIR(6) = 0;

% EDM augmented with RIR
Daug = zeros(6,6);
Daug(1:5,1:5) = D;
Daug(6,:) = RIR;
Daug(:,6) = RIR';

fprintf('Expected rank of the matrix Daug is: %d\n',dim+2);
fprintf('Actual rank of the matrix Daug is  : %d\n',rank(Daug));

% estimating mic location from real and virtual sound sources, and RIR
[x1out,y1out] = circcirc(s_loc(1),s_loc(2),RIR(1)^(1/2),sT(1,1),sT(2,1),RIR(2)^(1/2));
[x2out,y2out] = circcirc(s_loc(1),s_loc(2),RIR(1)^(1/2),sT(1,2),sT(2,2),RIR(3)^(1/2));
x1 = [x1out; y1out];
x2 = [x2out; y2out];

prevMin = Inf;
for i = 1:size(x1,2)    % #columns
    for j = 1:size(x2,2)
        x1x2dist = norm(x1(:,i)-x2(:,j));
        if x1x2dist<prevMin
            prevMin = x1x2dist;
            iMin = i;
            jMin = j;
        end
    end
end

mic_loc_estimate = x1(:,iMin);

fprintf('Original mic location was: (%.2f,%.2f)\n',mic_loc);
fprintf('Estimated mic location is: (%.2f,%.2f)\n',mic_loc_estimate);

