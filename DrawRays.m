function DrawRays(app)

hold on
h = gca;
delete(findobj(h, 'Type', 'Text'))
delete(findobj(h, 'Type', 'Line'))
delete(findobj(h, 'Type', 'Patch'))

%Radius of probe beam /mm
beamradius = 50;
%F number of emitted rays
fnumber = min(app.xpos)/90;

% xpos contains the positions of the lenses
xpos = app.xpos;
% flength contains the focal lengths of the lenses
flength = app.flength;

% This section turns the lens configuration into two variables:
% types - this is a cell array of strings. l for lens, d for free-space
% params - this is an array of numbers. Focal length for lenses, distances
% for free-space propagation

% Find the first lens
[~,inds] = sort(xpos);
types{1} = 'd';
param(1) = xpos(inds(1));

% Loop through the lenses and add items to the 'types' and 'params'
% variables

for m = 1:length(inds)
    types{length(types)+1} = 'l';
    param = [param flength(inds(m))];
    if(m < length(inds))
        types{length(types)+1} = 'd';
        param = [param xpos(inds(m+1))-xpos(inds(m))];
    end
    
end

% Change nrays to add more 'image rays'
nrays = 5;
thetamax = atan(1/(2*fnumber));
thetavec = [0 linspace(thetamax/nrays,thetamax,nrays-1)];
hvec = [beamradius zeros(1,nrays-1)];

for n = 1:nrays
    rays(n) = struct;
end

%Set up rays
for n = 1:nrays
    % Height - vertical dimension
    rays(n).hvec = [hvec(n)];
    % Angle
    rays(n).thetavec = [thetavec(n)];
    % Distance - longitudinal dimension
    rays(n).dvec = [0];
end

%Raytrace
for n = 1:length(types)
    for m = 1:nrays
        switch types{n}
            case 'l'
                rays(m) = PassThroughLens(rays(m), param(n));
            case 'd'
                rays(m) = PropagateFreeSpace(rays(m), param(n));
        end
    end
end

%Plot lenses
dcurr = 0;
lcount = 0;
for n = 1:length(types)
    switch types{n}
        case 'l'
            lcount = lcount+1;
            lens_f(lcount) = param(n);
            lens_d(lcount) = dcurr;
            % This draws a section of an ellipse for the lens
            y = -50:50;
            x = lens_d(lcount) + sign(lens_f(lcount))*(2000/(abs(lens_f(lcount)) + 100))*(sqrt(60^2 - 50^2) + sqrt(60^2 - y.^2));
            fill(x-min(x)+lens_d(lcount), y, [0.2 0.2 0.2], 'FaceAlpha', 0.1, 'EdgeColor', 'none')
        case 'd'
            dcurr = dcurr + param(n);
    end
end

% Find image distance and magnification
image = 0;
M = 1;
for n = 1:lcount
    u = lens_d(n) - image;
    f = lens_f(n);
    v = u*f/(u-f);
    image = lens_d(n) + v;
    M = M*v/u;
end

% Raytrace from last lens to image position
for m = 1:nrays
    rays(m) = PropagateFreeSpace(rays(m), image - xpos(inds(end)));
end

%Plot rays
for n = 1:nrays
    
    if (rays(n).thetavec(1) == 0)
        plot(rays(n).dvec, rays(n).hvec, 'Color', h.ColorOrder(2,:))
        plot(rays(n).dvec, -rays(n).hvec, 'Color', h.ColorOrder(2,:))
    else
        plot(rays(n).dvec, rays(n).hvec, 'Color', h.ColorOrder(1,:))
        plot(rays(n).dvec, -rays(n).hvec, 'Color', h.ColorOrder(1,:))
    end
    
    %fill([rays(end).dvec fliplr(rays(end).dvec)], [rays(end).hvec -rays(end).hvec], h.ColorOrder(1,:),...
    %    'FaceAlpha', 0.1, 'EdgeColor', 'none')
end

textCol = [.9 .9 .9];

if(image < max(app.xpos))
    textCol = [1 .9 .9];
end

text(image*1.02, 0, ['Mag = ' char(10) num2str(M) char(10) 'Position = ' char(10) num2str(image)], ...
    'EdgeColor', 'none', ...
    'BackgroundColor', textCol, ...
    'FontName', 'Futura', ...
    'FontSize', 12)
xlabel('Distance From Object /mm', 'FontSize', 12)
ylabel('Lateral Distance', 'FontSize', 12)
set(gca, 'FontSize', 12)
set(gcf, 'Color', 'white')
xlim([0 app.xmax])
ylim([-3*beamradius 3*beamradius])
h.YTickLabel = [];

line([image image], h.YLim, 'LineStyle', '--', 'Color', 'black')

if(app.drawDist)
    xposes = [0 sort(xpos) image];
    
    for n = 2:length(xposes)-1
        line([xposes(n-1) + 50 xposes(n)-50],[1.1*beamradius 1.1*beamradius], 'Color', 'black')
        text(mean(xposes(n-1:n)), 1.3*beamradius, num2str(round(xposes(n) - xposes(n-1))), 'EdgeColor', 'none', ...
            'BackgroundColor', textCol, ...
            'FontName', 'Futura', ...
            'FontSize', 12,...
            'HorizontalAlignment', 'center',...
            'ButtonDownFcn', @app.clickText)
    end
    
    for n = length(xposes):length(xposes)
        line([xposes(n-1) + 50 xposes(n)-50],[55 55], 'Color', 'black')
        text(mean(xposes(n-1:n)), 1.3*beamradius, num2str(round(xposes(n) - xposes(n-1))), 'EdgeColor', 'none', ...
            'BackgroundColor', textCol, ...
            'FontName', 'Futura', ...
            'FontSize', 12,...
            'HorizontalAlignment', 'center')
    end
end

if(app.drawFlength)
    for n = 1:length(xpos)
        line([xpos(n) xpos(n)], [-1.5*beamradius -1.1*beamradius], 'Color', 'black')
        text(xpos(n), -1.5*beamradius, num2str(round(flength(n))), 'EdgeColor', 'none', ...
            'BackgroundColor', textCol, ...
            'FontName', 'Futura', ...
            'FontSize', 12,...
            'HorizontalAlignment', 'center',...
            'ButtonDownFcn', @app.clickText)
    end
end

FormatPlot();

hold off


end

function ray = PassThroughLens(ray, f)

hnew = ray.hvec(end);
thetanew = -ray.hvec(end)/f + ray.thetavec(end);
dnew = ray.dvec(end);
ray.hvec = [ray.hvec hnew];
ray.thetavec = [ray.thetavec thetanew];
ray.dvec = [ray.dvec dnew];

end

function ray = PropagateFreeSpace(ray, d)

hnew = ray.hvec(end) + d*ray.thetavec(end);
thetanew = ray.thetavec(end);
dnew = ray.dvec(end) + d;
ray.hvec = [ray.hvec hnew];
ray.thetavec = [ray.thetavec thetanew];
ray.dvec = [ray.dvec dnew];

end
