

function [x, y] = trAIner(obj, action, x, y)

GetSoloFunctionArgs;


switch action

    case 'init',   % ------------ CASE INIT ----------------
        

        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]); next_row(y,1.5);
%        SoloParamHandle(obj, 'motor_num', 'value', 0);
        
        %added by ZG 10/1/11
        SoloParamHandle(obj, 'motor_num', 'value', 1);
        SoloParamHandle(obj, 'lateral_motor_num', 'value', 2);
        
        % List of pole positions
        SoloParamHandle(obj, 'previous_pole_positions', 'value', []);        
                
        
        % Set limits in microsteps for actuator. Range of actuator is greater than range of
        % our Del-Tron sliders, so must limit to prevent damage.  This limit is also coded into Zaber
        % TCD1000 firmware, but exists here to keep GUI in range. If a command outside this range (0-value)
        % motor driver gives error and no movement is made.
        SoloParamHandle(obj, 'motor_max_position', 'value', 300000);  
        SoloParamHandle(obj, 'trial_ready_times', 'value', 0);
        
        
        

        MenuParam(obj, 'trAIner_show', {'view', 'hide'}, 'hide', x, y, 'label', 'trAIner Control', 'TooltipString', 'Control trAIner');
        set_callback(trAIner_show, {mfilename,'hide_show'});

        next_row(y);
        SubheaderParam(obj, 'sectiontitle', 'trAIner Control', x, y);

        parentfig_x = x; parentfig_y = y;
       
        
        % ---  Make new window for motor configuration
        SoloParamHandle(obj, 'trAInerfig', 'saveable', 0);
        trAInerfig.value = figure('Position', [3 800 410 245], 'Menubar', 'none',...
            'Toolbar', 'none','Name','trAIner Control','NumberTitle','off');

        x = 1; y = 1;

        %       PushbuttonParam(obj, 'serial_open', x, y, 'label', 'Open serial port');
        %       set_callback(serial_open, {mfilename, 'serial_open'});
        %       next_row(y);

       
       
%         PushbuttonParam(obj, 'reset_motors_firmware', x, y, 'label', 'Reset Zaber firmware parameters',...
%             'TooltipString','Target acceleration, target speed, and microsteps/step');
%         set_callback(reset_motors_firmware, {mfilename, 'reset_motors_firmware'});
%         next_row(y);

        PushbuttonParam(obj, 'Right', x, y, 'label', 'Right');
        set_callback(read_positions, {mfilename, 'read_positions'});
        
          PushbuttonParam(obj, 'Left', x, y, 'label', 'Left');
        set_callback(read_positions, {mfilename, 'read_positions'});
        
          PushbuttonParam(obj, 'Absent', x, y, 'label', 'Absent');
        set_callback(read_positions, {mfilename, 'read_positions'});
        
        SubheaderParam(obj, 'title', 'next rial type', x, y);
        
        next_column(x); y = 1;
        
        PushbuttonParam(obj, 'read_positions', x, y, 'label', 'Read position');
        set_callback(read_positions, {mfilename, 'read_positions'});
  
        next_row(y);
        NumEditParam(obj, 'motor_position', 0, x, y, 'label', ...
            'Motor position','TooltipString','Absolute position in microsteps of motor.');
        set_callback(motor_position, {mfilename, 'motor_position'});
        
        next_row(y);
        SubheaderParam(obj, 'title', 'Read/set position', x, y);

        
        
        
        %--------------- extreme positions for the multi-pole task --------------------------------
        next_row(y);
        NumEditParam(obj, 'no_pole_position_ant', 180000, x, y, 'label', ...
            '"No" ant position','TooltipString','Far no trial position in microsteps.');
        
        next_row(y);
        NumEditParam(obj, 'no_pole_position_pos', 100001, x, y, 'label', ...
            '"No" pos position','TooltipString','Near no trial position in microsteps.');
        
        next_row(y);
        NumEditParam(obj, 'yes_pole_position_ant', 100000, x, y, 'label', ...
            '"Yes" ant position','TooltipString','Far yes trial position in microsteps.');        
        
        next_row(y);
        NumEditParam(obj, 'yes_pole_position_pos', 20000, x, y, 'label', ...
            '"Yes" pos position','TooltipString','Near yes trial position in microsteps.');
        %%%psm below 
        next_row(y);
        NumEditParam(obj, 'Absent_pole_position', 180000, x, y, 'label', ...
            '"Absent" lat position','TooltipString','out of range anterior trial.');        
        
        %%%psm above
% 
%         next_row(y);
%         NumEditParam(obj, 'num_of_pole_position', 5, x, y, 'label', ...
%             'Pole positions','TooltipString','Number of Yes/No pole position');
% 
%         % switch between 2 pole task and multi-pole
%         next_row(y);
%         ToggleParam(obj, 'multi_go_position', 0, x, y, 'label', 'Multi Go Positions',...
%             'TooltipString', 'Multiple pole position will be used.');
        %-----------------------------------------------------------
        
        
        
        next_row(y);
        NumEditParam(obj, 'motor_move_time', 2, x, y, 'label', ...
            'motor move time','TooltipString','set up time for motor to move.');

        next_row(y)
        PushbuttonParam(obj, 'read_lateral_positions', x, y, 'label', 'Read lateral position');
        set_callback(read_lateral_positions, {mfilename, 'read_lateral_positions'});

        next_row(y);
        NumEditParam(obj, 'lateral_motor_position', 180000, x, y, 'label', ...
            'lateral_motor_position','TooltipString','Absolute position in microsteps of motor.');
        set_callback(lateral_motor_position, {mfilename, 'lateral_motor_position'});

        next_row(y);
        SubheaderParam(obj, 'title', 'Trial position', x, y);
        

        MotorsSection(obj,'hide_show');
        MotorsSection(obj,'read_positions');
        MotorsSection(obj,'read_lateral_positions');
        
        x = parentfig_x; y = parentfig_y;
        set(0,'CurrentFigure',value(myfig));
        return;

    case 'move_next_side', % --------- CASE MOVE_NEXT_SIDE -----
       
        next_side = SidesSection(obj,'get_next_side');
       

            if next_side == 'r'
                next_pole_position = value(round(rand*(yes_pole_position_ant - yes_pole_position_pos)+yes_pole_position_pos));
            elseif next_side == 'l'
                next_pole_position = value(round(rand*(no_pole_position_ant - no_pole_position_pos)+no_pole_position_pos));
            elseif next_side == 'a'%-psm
                if rand(1)>=.5; %chooses randomly which pole position to mimic, note that the probabilites are 
                    %not dependent on the probabilities of left port or right port. but just random
                next_pole_position = value(round(rand*(yes_pole_position_ant - yes_pole_position_pos)+yes_pole_position_pos));
                else
                next_pole_position = value(round(rand*(no_pole_position_ant - no_pole_position_pos)+no_pole_position_pos)); 
                end
                else%psm
                error('un-recognized type for next_side');
            end

            half_point     = round(value(no_pole_position_pos+yes_pole_position_ant)/2);%#
            half_point_lat = round(value(lateral_motor_position+Absent_pole_position)/2);%#
            if  next_side == 'a'%-psm
                %we havce to ahve something that knows the set lateral position  lateral_motor_position
        absent_position = value(Absent_pole_position);%set position to lateral position for the absent trial
        tic
%         move_absolute(motors,half_point_lat,value(lateral_motor_num));
        move_absolute_Sequence3(motors,{half_point,next_pole_position},value(motor_num),...
            {half_point_lat,absent_position},value(lateral_motor_num));
%         move_absolute_Sequence(motors,{half_point_lat,absent_position},value(lateral_motor_num));
%         move_absolute(motors,absent_position,value(lateral_motor_num));
        movetime = toc
            else
        absent_position = value(lateral_motor_position);
        %this movetime below is dependent on the lateral movement as well
        %which is set for absolute movement which needs to be corrected later
        tic 
%         move_absolute(motors,half_point_lat,value(lateral_motor_num));
        move_absolute_Sequence3(motors,{half_point,next_pole_position},value(motor_num),...
            {half_point_lat,absent_position},value(lateral_motor_num));
%         move_absolute_Sequence(motors,{half_point_lat,absent_position},value(lateral_motor_num));
%         move_absolute(motors,absent_position,value(lateral_motor_num));
        movetime = toc
            end
        if movetime<value(motor_move_time) % Should make this min-ITI a SoloParamHandle
            pause( value(motor_move_time)-movetime);
        end

        MotorsSection(obj,'read_positions');        
        trial_ready_times.value = clock;  
        
        previous_pole_positions(n_started_trials) = next_pole_position;        
        

        return;
        

    
    case 'get_previous_pole_position',   % --------- CASE get_next_pole_position ------
        if isempty(value(previous_pole_positions))
            x = nan;
        else
            x = previous_pole_positions(length(previous_pole_positions));
        end
        return;

    case 'get_all_previous_pole_positions',   % --------- CASE get_next_pole_position ------
        x = value(previous_pole_positions);
        return;

    case 'get_yes_pole_position_easy'
        x = value(yes_pole_position_ant);
        return

    case 'get_no_pole_position_easy'
        x = value(no_pole_position_pos);
        return

    case 'get_num_of_pole_position'
       
            x = 1;
       
        return
        
        
    
        
    case 'motors_home',     %modified by ZG 10/1/11
%         disp(motors);
%         disp(value(motor_num));
        move_home(motors, value(motor_num));
        return;

    case 'serial_open',
        serial_open(motors);
        return;

    case 'serial_reset',     
        close_and_cleanup(motors);
        
        global motors_properties;
        global motors; 
        
        if strcmp(motors_properties.type,'@FakeZaberAMCB2')
            motors = FakeZaberAMCB2;
        else
            motors = ZaberAMCB2;
        end
        
        serial_open(motors);
        return;

    case 'motors_stop',
        stop(motors);
        return;

    case 'motors_reset',
        reset(motors);
        return;

    case 'reset_motors_firmware',
        set_initial_parameters(motors)
        display('Reset speed, acceleration, and motor bus ID numbers.')
        return;

    case 'motor_position',
        position = value(motor_position);
        if position > value(motor_max_position) | position < 0
            p = get_position(motors,value(motor_num));
            motor_position.value = p;
        else
            move_absolute(motors,position,value(motor_num));
        end
        return;
        
     case 'lateral_motor_position',
        position = value(lateral_motor_position);
        if position > value(motor_max_position) | position < 0
            p = get_position(motors,value(lateral_motor_num));
            lateral_motor_position.value = p;
        else
            move_absolute(motors,position,value(lateral_motor_num));
        end
        return;
        
    case 'read_positions'
        p = get_position(motors,value(motor_num));
        motor_position.value = p;
        return;

     case 'read_lateral_positions'
        p = get_position(motors,value(lateral_motor_num));
        lateral_motor_position.value = p;
        return;
        

        
        
        % --------- CASE HIDE_SHOW ---------------------------------

    case 'hide_show'
        if strcmpi(value(motor_show), 'hide')
            set(value(motorfig), 'Visible', 'off');
        elseif strcmpi(value(motor_show),'view')
            set(value(motorfig),'Visible','on');
        end;
        return;


    case 'reinit',   % ------- CASE REINIT -------------
        currfig = gcf;

        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

        delete(value(myaxes));

        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);

        % Reinitialise at the original GUI position and figure:
        [x, y] = feval(mfilename, obj, 'init', x, y);

        % Restore the current figure:
        figure(currfig);
        return;
end


