% This program converts the Mode Transition table to Matlab code

% Copyright Natasha Jeppu, natasha.jeppu@gmail.com
% http://www.mathworks.com/matlabcentral/profile/authors/5987424-natasha-jeppu

clear all
clc

% Offset of the modes
% Therac
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

% % Define the mode variable names here

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
% Therac - 25
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
% Therac - 25
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
nc = size(cond,1);
ic = 0;
imode = 1;
delete mfile.txt
diary mfile.txt

disp(['nt = ' num2str(nt) ' ; nc = ' num2str(nc) ' ;']);
disp('Tr = zeros(nt,1); C = zeros(nc,1);')
disp('for i = 1:nt; Tr(i) = u(i,1); end  % Assign triggers from input U')
disp('for i = 1:nc; C(i) = u(i+nt,1); end % Assign conditions from input U')
for i = 1:size(mode,1)
    disp([mode{i} ' = u(' num2str(i+nt+nc) ',1);'])
end
disp('% Assign the trigger to one based on priority');
disp('% Add additonal conditions to enable triggers here');
disp('TRIG = 0;');
IFS={'if '
     'elseif '};
 ifs = 1;
for i = 1:nt
   disp([IFS{ifs} ' Tr(' num2str(i) ') == 1, TRIG = ' num2str(i) ';  % ' trig{i} ])
   ifs = 2;
end
disp('end');
imode=1;istatec = 0;
ifs = 1;

for i = 1:ns  % no of states
    istatec = istatec+1;
    
    for j = 1:nt   % no of triggers
        if T(i,j) ~= 0
            if T(i,j) < 100   % only one 
                if C(i,j) == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' && (C(' num2str(C(i,j)) ') == 1)']; % only one condition
                    condisp = [cond{C(i,j)} ' is True'];
                end
                ic=ic+1;
                if(~strcmp(state{i},state{T(i,j)+offset(i)}))         
                    disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{T(i,j)+offset(i)} ' if condition ' condisp ]);
                    disp([IFS{ifs} ' (' mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(T(i,j)) ';']); 
                    if ifs == 1, ifs = 2; end
                else
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{T(i,j)+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' (' mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(T(i,j)) ';']); 
                   if ifs == 1, ifs = 2; end
                end
                
            elseif T(i,j) >= 100  && T(i,j) <= 9999% there are two transitions
                a=T(i,j)-fix(T(i,j)/100)*100;
                b=C(i,j)-fix(C(i,j)/100)*100;
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' && (C(' num2str(b) ') == 1)']; % only one condition
                    condisp = [cond{b} ' is True'];
                end 
                ic = ic+1;
                if(~strcmp(state{i},state{a+offset(i)}))
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' (' mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end
                else
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' (' mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end
                end
                
                a=fix(T(i,j)/100);  % get the second transition
                b=fix(C(i,j)/100);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' && (C(' num2str(b) ') == 1)']; % only one condition
                    condisp = [cond{b} ' is True'];
                end 
                ic = ic+1;
                if(~strcmp(state{i},state{a+offset(i)}))
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' (' mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end 
                else
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' ('  mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end
                end
                
               elseif  T(i,j) > 9999% there are three transitions
                    
                a=T(i,j)-fix(T(i,j)/100)*100;
                b=C(i,j)-fix(C(i,j)/100)*100;
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' && (C(' num2str(b) ') == 1)']; % only one condition
                    condisp = [cond{b} ' is True'];
                end 
  
                ic = ic+1;
                if(~strcmp(state{i},state{a+offset(i)}))
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' (' mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end 
                else
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' ('  mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end
                end
                    
                a=T(i,j)-fix(T(i,j)/10000)*10000;a=fix(a/100);  % gets the second
                b=C(i,j)-fix(C(i,j)/10000)*10000;b=fix(b/100);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' && (C(' num2str(b) ') == 1)']; % only one condition
                    condisp = [cond{b} ' is True'];
                end  
                ic = ic+1;
                if(~strcmp(state{i},state{a+offset(i)}))
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' (' mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end 
                else
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' ('  mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end
                end
                
                a=fix(T(i,j)/10000);  % get the second transition
                b=fix(C(i,j)/10000);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' && (C(' num2str(b) ') == 1)']; % only one condition
                    condisp = [cond{b} ' is True'];
                end  
                ic = ic+1;
                if(~strcmp(state{i},state{a+offset(i)}))
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' (' mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end 
                else
                   disp(['% ' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ]);
                   disp([IFS{ifs} ' ('  mode{imode} ' == ' num2str(istatec) ') && (TRIG == ' num2str(j) ')' condt ' ; ' mode{imode} ' = ' num2str(a) ';']); 
                   if ifs == 1, ifs = 2; end
                end
                
            end
        end
    end
    if (offset(i) ~= offset(i+1))
        disp('end     ');
        disp (['%   ================================================']);
        disp('  ');
        imode=imode+1;
        istatec = 0;
        ifs = 1;
        if i~=ns
        end
    end
end

disp('% ============== Set the outputs ===========');
im = size(mode,1);
disp(['y = zeros(' num2str(im) ',1);']);
for i = 1:im
    disp(['y(' num2str(i) ') = ' mode{i} ';'])
end
diary off