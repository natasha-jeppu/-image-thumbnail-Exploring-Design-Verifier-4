% This program converts the Mode Transition table to NuSMV code
% NuSMV  is available at http://nusmv.fbk.eu/
% NuSMV: a new symbolic model checker

% Copyright Natasha Jeppu, natasha.jeppu@gmail.com
% http://www.mathworks.com/matlabcentral/profile/authors/5987424-natasha-jeppu

% Therac 25
clear all
clc

% Offset of the modes

offset=[0
0
0
0
0
0
6
6
6
6
6
11
11
11
11
15
15
];

offset = [offset;-1]; % This is required because of the logic looks at the next cell. Leave it as such.

% Define the trigger variables here

trig={'UP'
    'ENT'
    'XT'
    'ET'
    'BT'
    'TIM8'
    'RESET'
    'TICK'
};

% Define the mode variable names here

mode={'INTER'
'LEVEL'
'SPREAD'
'FIRE'
};

% Define the state variable names here

state={'EDIT'
'EBDATAE'
'EBDATAD'
'XBDATAE'
'XBDATAD'
'TADMIN'
'NEITHER'
'XB'
'EB'
'X2E'
'E2X'
'INPLACE'
'MOVOUT'
'OUTPLACE'
'MOVIN'
'WAIT'
'FIRED'
};

% Define the condition variable names here

cond={'C1'
};

% Transition matrix
% Therac 25
T=[0	0	4	2	0	0	0	0
1	3	0	0	0	0	0	0
2	0	0	0	6	0	0	0
1	5	0	0	0	0	0	0
4	0	0	0	6	0	0	0
0	1	0	0	0	0	0	0
0	0	2	3	0	0	0	0
0	0	0	4	0	0	1	0
0	0	5	0	0	0	1	0
0	0	0	0	0	0	0	3
0	0	0	0	0	0	0	2
0	0	0	2	0	0	0	0
0	0	4	0	0	3	0	0
0	0	4	0	0	0	0	0
0	0	0	2	0	1	0	0
0	0	0	0	2	0	0	0
0	0	0	0	0	0	0	1
];


%Condition Matrix
% Therac 25
C=[0	0	1	1	0	0	0	0
1	1	0	0	0	0	0	0
1	0	0	0	1	0	0	0
1	1	0	0	0	0	0	0
1	0	0	0	1	0	0	0
0	1	0	0	0	0	0	0
0	0	1	1	0	0	0	0
0	0	0	1	0	0	1	0
0	0	1	0	0	0	1	0
0	0	0	0	0	0	0	1
0	0	0	0	0	0	0	1
0	0	0	1	0	0	0	0
0	0	1	0	0	1	0	0
0	0	1	0	0	0	0	0
0	0	0	1	0	1	0	0
0	0	0	0	1	0	0	0
0	0	0	0	0	0	0	1
];

ns = size(T,1);
nt=length(trig);
nc=size(cond,1);

ic = 0;
imode = 1;
delete test.smv
diary test.smv
disp ('MODULE main');
disp ('VAR');

for t = 1:nt
    disp ([trig{t} ':boolean;' ]);
end
disp('  ');

for i=1:nc %take number of conditions
    disp ([cond{i} ':boolean;' ]);
end
disp('  ');   
disp('TRIG:{0');
for t=1:nt
    disp([',' num2str(t)]);
end
disp('};');

imode=2;
disp([mode{1} ':{']);
for i=1:ns-1
   if offset(i)~=offset(i+1)
       disp([state{i} ' };']);
       disp([mode{imode} ':{']);
       imode=imode+1;    
   else
       disp([state{i} ',']);
   end
end
if offset(ns-1)==offset(ns)
    disp([state{ns} ' };']);
else
    disp([mode{imode} ':{']);
    disp([state{ns} ' };']);
end
disp('   ');
disp ('ASSIGN');
imode = 2;
disp(['init(' mode{1} ') :=' state{1} ';']);
for i=1:ns-1
    if offset(i)~=offset(i+1)
        disp(['init(' mode{imode} ') :=' state{i+1} ';']);
        imode=imode+1;
    end
end
disp('   ');
disp('-- Add additonal conditions to set the triggers');
disp ('TRIG := case');
for t = 1:nt
    disp ([trig{t} ' = TRUE :' num2str(t) ';' ]);
end
disp ('TRUE :0;');
disp ('esac;');
disp('  ');
imode=1;
disp(['next(' mode{imode} '):=case']);
for i = 1:ns  % no of states
    for j = 1:nt   % no of triggers
        if T(i,j) ~= 0
            if T(i,j) < 100   % only one 
                if C(i,j) == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{C(i,j)}]; % only one condition
                    condisp = cond{C(i,j)};
                end
                ic=ic+1;
                if(~strcmp(state{i},state{T(i,j)+offset(i)}))         
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{T(i,j)+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{T(i,j)+offset(i)} ';']);
                else
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{T(i,j)+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{T(i,j)+offset(i)} ';']); 
                end
                
            elseif T(i,j) >= 100  && T(i,j) <= 9999% there are two transitions
                a=T(i,j)-fix(T(i,j)/100)*100;
                b=C(i,j)-fix(C(i,j)/100)*100;
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end
                
                a=fix(T(i,j)/100);  % get the second transition
                b=fix(C(i,j)/100);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end  
                
                
               elseif  T(i,j) > 9999% there are three transitions
                    
                a=T(i,j)-fix(T(i,j)/100)*100;
                b=C(i,j)-fix(C(i,j)/100)*100;
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end  
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end
                    
                a=T(i,j)-fix(T(i,j)/10000)*10000;a=fix(a/100);  % gets the second
                b=C(i,j)-fix(C(i,j)/10000)*10000;b=fix(b/100);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end  
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end
                
                a=fix(T(i,j)/10000);  % get the second transition
                b=fix(C(i,j)/10000);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end  
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end
                
            end
        end
    end
    if (offset(i) ~= offset(i+1))
        disp (['TRUE :' mode{imode} ';']);
        disp('esac;');
        disp('  ');
        imode=imode+1;
        if i~=ns
            disp(['next(' mode{imode} '):=case']);
        end
    end
end

disp('  ');
disp('-- ==============');
disp('  ')
disp('-- Put LTLSPEC here - Example');
disp('-- LTLSPEC G (( M1 = M1_S5 ) -> M2 = M2_S2)');
diary off