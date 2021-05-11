function plot_trhliny(  )
%PLOT_TRHLINY Summary of this function goes here
%   Detailed explanation goes here
frac_start_end={[0.3 0.2], [0.9 0.2]
                [0.3 0.8], [0.9 0.8]
                [0.4 0.1], [0.4 0.7]
                [0.1 0.3], [0.7 0.9]};
hold on
for i=1:length(frac_start_end)
    startpoint=frac_start_end{i,1}*10;
    endpoint=frac_start_end{i,2}*10;
    plot3([startpoint(1) endpoint(1)],[startpoint(2) endpoint(2)],[1e10,1e10],'Color','k','LineWidth',2)
end

hold off
end

