function [] = lunghAO1_timer_fcn(obj, event, lid)

    global private_lunghAO1_list;
    TimesUp(private_lunghAO1_list{lid});
    