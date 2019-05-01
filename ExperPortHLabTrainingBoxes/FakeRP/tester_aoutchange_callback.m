function [] = tester_AOutchange_callback(lh1, lh2)

    [AOut1, AOut2] = lunghAO1_gui_AOutchange_callback(lh1);
    
    SetTagVal(lh2, 'ch1in', AOut1);
    SetTagVal(lh2, 'ch2in', AOut2);
    