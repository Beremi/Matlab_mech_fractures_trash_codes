n=length(D);

%figure
hold on

% for i=1:n-1
%    plot([i i]+0.5,[1e-7,1],':k','LineWidth',2) 
% end

for j=1:n
    D_l=D{j};
    D_l(1)=D_l(1)*2;
    D_l(end)=D_l(end)*2;
    x=linspace(j-1,j,length(D_l));
    x(1)=x(1)+0.5/length(D_l);
    x(end)=x(end)-0.5/length(D_l);
   plot(x+0.5,D_l,'c','LineWidth',2) 
end
% set(gca,'YScale','log')
% xlim([0 n]+0.5)
% ylim([1e-6 1e-3])
%  box on
% grid on