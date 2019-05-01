function reporter(obj, event)

global private_lunghAO1_list;
id = get(obj, 'UserData');

lh1 = private_lunghAO1_list{id};
GetTagVal(lh1, 'StateMatrix'),
% obj, event, get(obj),
