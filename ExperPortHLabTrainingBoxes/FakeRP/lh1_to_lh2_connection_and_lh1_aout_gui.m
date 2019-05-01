function [] = lh1_to_lh2_connection_and_lh1_AOut_gui(lh1, lh2)

    [AOut1, AOut2] = lunghAO1_gui_AOutchange_callback(lh1);
    
    % fprintf(1, 'AOut1 = %.2f  AOut2 = %.2f\n', AOut1, AOut2);
    SetTagVal(lh2, 'ch1in', AOut1);
    SetTagVal(lh2, 'ch2in', AOut2);
