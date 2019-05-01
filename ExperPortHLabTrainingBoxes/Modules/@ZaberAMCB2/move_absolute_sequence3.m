function move_absolute_sequence3(z, seq, unit, lat_seq, lat_unit)
%
% Move actuator to a sequence of absolute positions, without pausing at each 
% position. 
%
% 12/06, DHO
%move_absolute_sequence(motors,{half_point,next_pole_position},value(motor_num));
%move_absolute(motors,position,value(lateral_motor_num));
% warning off MATLAB:instrcb:invalidcallback

if ~isa(seq,'cell')
    error('Argument seq must be a cell array')
end
if ~isa(lat_seq,'cell')
    error('Argument seq must be a cell array')
end
if length(seq) ~= length(lat_seq)
    error('seq length and lat_seq length must be equal')
end


seq(end+1)=seq(end);
seq(end-1)=num2cell(round(((seq{end}-seq{1})*(randBetween(.25, .5, 'both'))+seq{1})));%sets middle move pole offset
seq(1)    =num2cell(round(((seq{end}-seq{1})*(randBetween(.15, .3, 'both'))+seq{1})));%sets center pole
%position offset 

lat_seq(end+1)=lat_seq(end);
lat_seq(end-1)=num2cell(round(((lat_seq{end}-lat_seq{1})*(randBetween(.25, .5, 'both'))+lat_seq{1})));
lat_seq(1)    =num2cell(round(((lat_seq{end}-lat_seq{1})*(randBetween(.1, .2, 'both'))+lat_seq{1})));

%%%%%old jitter -psm
% randVarInRange = .5 + (.25-.5)*rand(1,1);
% seq(end+1)=seq(end);
% seq(end-1)=num2cell(round(((seq{end}-seq{1})*(randVarInRange*(rand()-0.5)*2)+seq{1})));
% 
% randVarInRange = .5 + (.25-.5)*rand(1,1);
% lat_seq(end+1)=lat_seq(end);
% lat_seq(end-1)=num2cell(round(((lat_seq{end}-lat_seq{1})*(randVarInRange*(rand()-0.5)*2)+lat_seq{1})));
%%%%%old jitter -psm

if z.sobj.BytesAvailable > 0
%     fread(z.sobj,z.sobj.BytesAvailable,'uint8');  % clear input buffer
    fscanf(z.sobj,'%s',z.sobj.BytesAvailable);
end

% jitter mode - jitters by uniform distro of [0 127]; if 
%  position >= 180000-128, jitters by NEGATIVE that.
jitter_mode = 1; % set to 0 to disable
if (jitter_mode == 1)
     jitter=127;
      lat_jitter=127;
    disp(['move_absolute_sequence3.m::jitter mode ON ; jittering by ' num2str(jitter) ' microsteps']); 
    disp(['move_absolute_sequence3.m::jitter mode ON ; jittering laterally by ' num2str(lat_jitter) ' microsteps']);
end

for k=1:length(seq)
    position = seq{k};
    lat_position = lat_seq{k};
    
    if (jitter_mode == 1)
        
        offs = round(jitter*rand);
        lat_offs = round(lat_jitter*rand);

        if (position < (180000-128))
            position = position + offs;
        else
            position = position - offs;
        end

        if (lat_position < (180000-128))
            lat_position = lat_position + lat_offs;
        else
            lat_position = lat_position - lat_offs;
        end
        
    end %end jitter mode
    cmd = ['/0 ' num2str(unit) ' move abs ' num2str(position)];
    lat_cmd = ['/0 ' num2str(lat_unit) ' move abs ' num2str(lat_position)];
    fprintf(z.sobj,cmd);
    fprintf(z.sobj,lat_cmd);
    

    disp(['move_absolute_sequence::command to zaber: ' cmd]);
     disp(['move_absolute_sequence::command to zaber: ' lat_cmd]);

    motor_status = 1;
    while motor_status ~= 0; % status 0 is idle
        %         fwrite(z.sobj,[unit 54 0 0 0 0],'uint8'); % Command 54: Return Status
        try
            motor_status = get_status(z,unit)+get_status(z,lat_unit);
        catch
            stop(z.sobj);
            reset(z.sobj);
            renumber_all(z.sobj);
            % If timeout error, clear buffer and try again:
            if z.sobj.BytesAvailable > 0
                 fscanf(z.sobj,'%s',z.sobj.BytesAvailable);
            end
              motor_status = get_status(z,unit)+get_status(z,lat_unit);
        end
        if motor_status ~= 0
            pause(0.01);
        end
    end
end





% set(z.sobj,'BytesAvailableFcnCount',6,'BytesAvailableFcnMode','byte')
% set(z.sobj,'BytesAvailableFcn',{@bytes_available_callback, z, unit, seq, k})
% % set(z.sobj,'BytesAvailableFcn',{@next_move, z, unit, seq, k})
% 
% position = seq{k};
% cmd = [unit 20 single_to_four_bytes(position)];
% fwrite(z.sobj,cmd,'uint8');%,'async'); % Maybe *not* asynch?

% 
% function next_move(obj,event,z,unit,seq,k)
% % display(['callbk run with k=' int2str(k)])
% ba = get(obj,'BytesAvailable');
% if ba > 0
%     [A,count,msg] = fread(obj,ba,'uint8');
% end
% k = k+1;
% move_absolute_sequence(z,unit,seq,k);




% %%
% function move_absolute_sequence(z, unit, seq, varargin)
% %
% % Move actuator to a sequence of absolute positions, without pausing at each 
% % position. Works by recursion.
% %
% % 12/06, DHO
% %
% 
% 
% if ~isa(seq,'cell')
%     error('Argument seq must be a cell array')
% end
% 
% if nargin > 3
%     k = varargin{1};
% else
%     k = 1;
% end
% 
% ba = get(z.sobj,'BytesAvailable');
% if k==1 && ba > 0
%     fread(z.sobj,ba,'uint8')  % clear input buffer
% end
% 
% if k > length(seq)
%     return
% end
% 
% % set(z.sobj,'BytesAvailableFcnCount',6,'BytesAvailableFcnMode','byte')
% set(z.sobj,'BytesAvailableFcn',{@next_move, z, unit, seq, k})
% 
% position = seq{k};
% cmd = [unit 20 single_to_four_bytes(position)];
% fwrite(z.sobj,cmd,'uint8');%,'async'); % Maybe *not* asynch?
% 
% 
% function next_move(obj,event,z,unit,seq,k)
% % display(['callbk run with k=' int2str(k)])
% ba = get(obj,'BytesAvailable');
% if ba > 0
%     [A,count,msg] = fread(obj,ba,'uint8');
% end
% k = k+1;
% move_absolute_sequence(z,unit,seq,k);
% 

