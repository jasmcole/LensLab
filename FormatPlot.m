function params = FormatPlot(varargin)

p = inputParser();

% Default settings. Can be overridden with label-name pairs in input
% e.g. MakeSeabornPlot('font', 'Arial')
p.addParameter('font', 'Gill Sans');
p.addParameter('width', 12);
p.addParameter('height', 6);
p.addParameter('fontsize', 24);
p.addParameter('markersize', 10);
p.addParameter('linewidth', 2);
p.addParameter('bgcolour', [0.98 0.98 0.98]);
p.addParameter('textcolour', [.3 .3 .3]);
p.parse(varargin{:})
params = p.Results;

font       = params.font;
width      = params.width;
height     = params.height;
fontsize   = params.fontsize;
markersize = params.markersize;
linewidth  = params.linewidth;
bgcolour   = params.bgcolour;
textcolour = params.textcolour;

if(verLessThan('matlab', '8.6'))
    ticklength = [0.01];
else
    ticklength = [0.01 0];
end
   
if(~verLessThan('matlab', '9.0'))
    fontsize = fontsize/1.5;
    linewidth = linewidth/2;
    markersize = markersize/2;
end

set(gca, 'FontSize', fontsize, 'FontName', font)
set(get(gca,'xlabel'),'fontsize',fontsize, 'FontName', font);
set(get(gca,'ylabel'),'fontsize',fontsize, 'FontName', font);
set(get(gca,'title'),'fontsize',fontsize, 'FontName', font);
set(gcf, 'color', 'white')
set(gcf, 'Units', 'inches')
set(gcf,'PaperPosition', [0 0 width height]);

h = gca;
h.Color = bgcolour;
h.XGrid = 'on';
h.XMinorGrid = 'on';
h.YGrid = 'on';
h.YMinorGrid = 'on';
h.GridColor = [.7 .7 .7];
h.GridAlphaMode = 'manual';
h.GridAlpha = 1;
h.MinorGridColor = [.85 .85 .85];
h.MinorGridAlphaMode = 'manual';
h.MinorGridAlpha = 0.7;
h.MinorGridLineStyle = '-';
h.GridLineStyle = '-';
h.Box = 'on';
h.YColor = textcolour;
h.XColor = textcolour;
h.FontName = font;
h.XLabel.FontName = font;
h.YLabel.FontName = font;

h.XRuler.TickLength = ticklength;
h.XRuler.Axle.ColorData = uint8([77; 77; 77; 255]);
h.XRuler.MinorTick = 'on';
h.YRuler.TickLength = ticklength;
h.YRuler.Axle.ColorData = uint8([77; 77; 77; 255]);
h.YRuler.MinorTick = 'on';

for n = 1:length(h.Children)
    hp = h.Children(n);
    switch class(hp)
        case 'matlab.graphics.chart.primitive.Line'
            hp.LineWidth = linewidth;
            hp.MarkerFaceColor = bgcolour;
            hp.MarkerSize = markersize;
        case 'matlab.graphics.chart.primitive.Contour'
            hp.LineWidth = linewidth;
        case 'matlab.graphics.primitive.Text'
            hp.BackgroundColor = bgcolour;
        case 'matlab.graphics.chart.primitive.Bar'
            hp.BarWidth = 1;
            hp.FaceColor = h.ColorOrder(1,:);
            hp.EdgeColor = 'none';
        case 'matlab.graphics.chart.primitive.ErrorBar'
            hp.LineWidth = linewidth;
            hp.Marker = 'o';
            hp.MarkerFaceColor = bgcolour;
            hp.MarkerSize = markersize;
    end
end

hf = gcf;
for n = 1:length(hf.Children)
    hp = hf.Children(n);
    switch class(hp)
        case 'matlab.graphics.illustration.Legend'
            hp.EdgeColor = 'none';
            if(strfind(hp.Location, 'outside'))
                hp.Color = 'white';
            else
                hp.Color = bgcolour;
            end
            hp.TextColor = textcolour;
    end
end

end