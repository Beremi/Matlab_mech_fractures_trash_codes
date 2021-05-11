DAMH_APERTURE=all_D;

DAMH_MULTIPLICITY=MH_MULTIPLICITY;


mean_aperture=sum(DAMH_APERTURE.*DAMH_MULTIPLICITY)/sum(DAMH_MULTIPLICITY);

ordering=[1 2 3 4];
std_aperture=sqrt(sum((DAMH_APERTURE-mean_aperture).^2.*DAMH_MULTIPLICITY)/sum(DAMH_MULTIPLICITY));

figure
subplot(1,4,3)
hold on
plot(0,0,'k-','LineWidth',2)
plot(0,0,'c:','LineWidth',2,'Color',[0.3010    0.7450    0.9330])
plot(0,0,'r-','LineWidth',2)
legend({'reference solution','mean value','standard deviation'})
start=1;
fin=24;
axeses=cell(4,1);
for i=1:4
    axeses{i}=subplot(1,4,ordering(i));
    hold on
    for j=1:4
        
        yyaxis left
        
        plot(linspace(j-1,j-1/100,24),all_DD(:,(i-1)*4+j),'k-','LineWidth',2)
        plot(linspace(j-1,j-1/100,24),mean_aperture(start:fin),'c:','LineWidth',2,'Color',[0.3010    0.7450    0.9330])
        
        

        ylim([0 1.6e-3])
        yticks((0:0.5:3.5)*1e-3)
        if ordering(i)>1
            yticklabels([])
        end
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        yyaxis right
        plot(linspace(j-1,j-1/100,24),std_aperture(start:fin),'r-','LineWidth',2)
        ylim([0 1.6e-4])
        yticks((0:0.5:3.5)*1e-4)
        if ordering(i)<4
            yticklabels([])
        end
        if j<4
            plot([j j],[0 1],'k-')
        end
        set(gca, 'YGrid', 'on', 'XGrid', 'off')
        start=start+24;
        fin=fin+24;
        xticks(0.5:1:3.5)
        xticklabels(1:4)
        box on
    end
    
end
for i=1:4
    pos = get(axeses{i}, 'Position');
    pos(1)=pos(1)-0.05;
    pos(2)=pos(2);
    pos(3) = pos(3)*1.25;
    pos(4) = pos(4)*0.9;
    
    set(axeses{i}, 'Position', pos)
end


set(findall(gcf,'-property','FontSize'),'FontSize',12)

% n=length(DAMH_APERTURE);
% x=linspace(0,1,18);
% y=linspace(0,1,100);
% res_frac=cell(n,16);
% for i=1:n
%     start=1;
%     fin=18;
%     for j=1:4
%         for l=1:4
%
%             res_frac{i,(j-1)*4+l}=interp1(x,DAMH_APERTURE(i,start:fin),y);
%             start=start+18;
%             fin=fin+18;
%         end
%     end
% end