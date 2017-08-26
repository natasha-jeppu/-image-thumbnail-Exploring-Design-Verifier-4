% This program converts the Mode Transition table text requirements

% Copyright Natasha Jeppu, natasha.jeppu@gmail.com
% http://www.mathworks.com/matlabcentral/profile/authors/5987424-natasha-jeppu

clear all
clc
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

trig={'UP'
    'ENT'
    'XT'
    'ET'
    'BT'
    'TIM8'
    'RESET'
    'TICK'
};

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

cond={'C1'
};

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
[ns,c]=size(T);
nt=length(trig);
ic = 0;
for i = 1:ns  % no of states
    for j = 1:nt   % no of triggers
        if T(i,j) ~= 0
            if T(i,j) < 100   % only one 
                if C(i,j) == 0  % there is no condition
                    condt = ' [No Condition required] ';
                else
                    condt = cond{C(i,j)}; % only one condition
                end
                ic = ic+1;
                if(strcmp(state{i},state{T(i,j)+offset(i)}))
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{T(i,j)+offset(i)} ' if condition ' condt ' Is TRUE']);
                else
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{T(i,j)+offset(i)} ' if condition ' condt ' Is TRUE']);
                end
                
            elseif T(i,j) >= 100  && T(i,j) <= 9999% there are two transitions
                a=T(i,j)-fix(T(i,j)/100)*100;
                if C(i,j) == 0  % there is no condition
                    condt = ' [No Condition required] ';
                else
                    b=C(i,j)-fix(C(i,j)/100)*100;
                    condt = cond{b}; % only one condition
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                else
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                end
                
                a=fix(T(i,j)/100);  % get the second transition
                if C(i,j) == 0  % there is no condition
                    condt = ' [No Condition required] ';
                else
                    b=fix(C(i,j)/100);
                    condt = cond{b}; % only one condition
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                else
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                end  
                
                
                elseif  T(i,j) > 9999% there are three transitions
                    
                a=T(i,j)-fix(T(i,j)/100)*100;
                if C(i,j) == 0  % there is no condition
                    condt = ' [No Condition required] ';
                else
                    b=C(i,j)-fix(C(i,j)/100)*100;
                    condt = cond{b}; % only one condition
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                else
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                end
                    
                a=T(i,j)-fix(T(i,j)/10000)*10000;a=fix(a/100);  % gets the second
                if C(i,j) == 0  % there is no condition
                    condt = ' [No Condition required] ';
                else
                    b=C(i,j)-fix(C(i,j)/10000)*10000;b=fix(b/100);
                    condt = cond{b}; % only one condition
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                else
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                end
                
                a=fix(T(i,j)/10000);  % get the second transition
                if C(i,j) == 0  % there is no condition
                    condt = ' [No Condition required] ';
                else
                    b=fix(C(i,j)/10000);
                    condt = cond{b}; % only one condition
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                else
                    disp([num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condt ' Is TRUE']);
                end
                
            end
        end
    end
end
