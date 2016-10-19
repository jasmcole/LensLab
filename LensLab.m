classdef LensLab < handle
    
    properties
        fig
        ax
        newLensBtn
        delLensBtn
        toggleTxt
        drawDistBtn
        drawFlengthBtn
        saveBtn
        loadBtn
        xmax
        Nlens
        flength
        xpos
        boundx
        isDragging
        isFocussing
        isChangingAxis
        buttonDownX
        isHover
        currLens
        lensBox
        leg
        drawDist
        drawFlength
    end
    
    methods
        % Constructor
        function app = LensLab
            
            app.fig = figure('MenuBar','none',...
                'NumberTitle','off','Name','Lens Lab',...
                'CloseRequestFcn',@app.closeApp,...
                'WindowButtonDownFcn',@app.buttonDown,...
                'WindowButtonUpFcn',@app.buttonUp,...
                'WindowButtonMotionFcn', @app.hoverMotion,...
                'OuterPosition', [100 500 1000 500],...
                'Resize', 'off'...
                );
            
            app.ax = axes('Parent',app.fig,...
                'Position',[.12 .1 .8 .8]);
            
            app.newLensBtn = uicontrol(app.fig, 'Style', 'pushbutton', 'String', '+ Lens',...
                'Units', 'normalized',...
                'Position', [.01 .9 0.06 0.08],...
                'BackgroundColor', [1 1 1],...
                'ForegroundColor',[.1 .1 .1],...
                'FontSize', 12, 'FontName', 'Futura',...
                'Callback', @app.addLens);
            
            app.delLensBtn = uicontrol(app.fig, 'Style', 'pushbutton', 'String', '- Lens',...
                'Units', 'normalized',...
                'Position', [.01 .8 0.06 0.08],...
                'BackgroundColor', [1 1 1],...
                'ForegroundColor',[.1 .1 .1],...
                'FontSize', 12, 'FontName', 'Futura',...
                'Callback', @app.delLens);
            
            app.toggleTxt = uicontrol(app.fig, 'Style', 'text', 'String', 'Toggle',...
                'Units', 'normalized',...
                'Position', [.01 .65 0.06 0.08],...
                'BackgroundColor', [1 1 1],...
                'ForegroundColor',[.1 .1 .1],...
                'FontSize', 12, 'FontName', 'Futura');
            
            app.drawDistBtn = uicontrol(app.fig, 'Style', 'pushbutton', 'String', 'Distances',...
                'Units', 'normalized',...
                'Position', [.01 .6 0.06 0.08],...
                'BackgroundColor', [1 1 1],...
                'ForegroundColor',[.1 .1 .1],...
                'FontSize', 12, 'FontName', 'Futura',...
                'Callback', @app.toggleDrawDist);
            
            app.drawFlengthBtn = uicontrol(app.fig, 'Style', 'pushbutton', 'String', 'F lengths',...
                'Units', 'normalized',...
                'Position', [.01 .5 0.06 0.08],...
                'BackgroundColor', [1 1 1],...
                'ForegroundColor',[.1 .1 .1],...
                'FontSize', 12, 'FontName', 'Futura',...
                'Callback', @app.toggleDrawFlength);
            
            app.saveBtn = uicontrol(app.fig, 'Style', 'pushbutton', 'String', 'Save',...
                'Units', 'normalized',...
                'Position', [.01 .2 0.06 0.08],...
                'BackgroundColor', [1 1 1],...
                'ForegroundColor',[.1 .1 .1],...
                'FontSize', 12, 'FontName', 'Futura',...
                'Callback', @app.save);
            
            app.saveBtn = uicontrol(app.fig, 'Style', 'pushbutton', 'String', 'Load',...
                'Units', 'normalized',...
                'Position', [.01 .1 0.06 0.08],...
                'BackgroundColor', [1 1 1],...
                'ForegroundColor',[.1 .1 .1],...
                'FontSize', 12, 'FontName', 'Futura',...
                'Callback', @app.load);
            
            % Number of lenses
            app.Nlens = 2;
            % Focal lengths
            app.flength = [500 500];
            % Positions
            app.xpos = [700 1700];
            % Size of bounding box
            app.boundx = 200;
            % Mouse states
            app.isDragging = false;
            app.isFocussing = false;
            app.isChangingAxis = false;
            app.isHover = false;
            % Currently selected lens
            app.lensBox = [];
            % Drawing option flags
            app.drawDist = true;
            app.drawFlength = true;
            % x-axis limit
            app.xmax = 3000;
            DrawRays(app);
        end
        
        function buttonDown(app,~,~)
            % Otherwise the mouse motion function is hoverMotion
            app.fig.WindowButtonMotionFcn = @app.mouseMotion;
            C = get (gca, 'CurrentPoint');
            x = C(1,1);
            app.buttonDownX = x;
        end
        
        function mouseMotion(app,~,~)
            C = get (gca, 'CurrentPoint');
            x = C(1,1);
            y = C(1,2);
            hylim = get(gca, 'YLim');
            height = hylim(2) - hylim(1);
            [offset, lens] = min(abs(x - app.xpos));
            
            % Change some property if the mouse is doing something...
            if(app.isDragging || app.isFocussing || app.isChangingAxis)
                
                lens = app.currLens;
                offset = abs(x - app.xpos(lens));
                
                if(app.isDragging)
                    % Translate lens
                    app.xpos(lens) = x;
                end
                
                if(app.isFocussing)
                    % Change the focal length
                    app.flength(lens) = offset*sign(x - app.xpos(lens));
                end
                
                if(app.isChangingAxis)
                    % Change the maximum x limit of the axis
                    offset = x - app.buttonDownX;
                    app.xmax = app.xmax - offset;
                    app.buttonDownX = app.buttonDownX + 0.01*offset;
                end
                
            % ...otherwise decide what to do with the mouse motion.
            else
                
                app.currLens = lens;
                
                % If far enough above the x-axis, select a lens
                if(y > hylim(1) + height*0.1)
                    
                    % If close enough to the centre of a lens, translate
                    % the lens
                    if(offset < 0.66*app.boundx)
                        app.isDragging = true;
                    end
                    
                    % If far enough from the centre of a lens, change the
                    % focal length
                    if(offset > 0.66*app.boundx && offset < app.boundx)
                        app.isFocussing = true;
                    end
                
                % If close to the x-axis, select the axis
                else
                    app.isChangingAxis = true;
                end
                
            end
            
            DrawRays(app);
            
            if(app.isDragging)
                title(['X-Position: ' num2str(app.xpos(lens)) ' mm'])
            end
            
            if(app.isFocussing)
                title(['Focal length: ' num2str(app.flength(lens)) ' mm'])
            end
            
        end
        
        % Default function invoked on mouse motion
        function hoverMotion(app,~,~)
            C = get (gca, 'CurrentPoint');
            x = C(1,1);
            y = C(1,2);
            [offset, lens] = min(abs(x - app.xpos));
            xl = get(gca, 'XLim');
            yl = get(gca, 'YLim');
            
            hovertarget = 'none';
            
            if(offset < app.boundx && abs(y) < 50)
                hovertarget = 'lens';
            end
            
            if(y < yl(1) + 0.1*(yl(2) - yl(1)))
                hovertarget = 'axis';
            end
            
            switch hovertarget
                
                case 'lens'
                    title(['Lens ' num2str(lens) ': position ' num2str(app.xpos(lens))...
                        ' mm, focal length ' num2str(app.flength(lens)) ' mm'])
                    x = app.xpos(lens);
                    
                    patchcol = [1 0 0];
                    msg = 'Drag to change focal length';
                    
                    if(offset < 0.66*app.boundx)
                        patchcol = [0 0 1];
                        msg = 'Drag to change position';
                    end
                    
                    DrawRays(app);
                    hold on
                    app.lensBox = patch([x-app.boundx x+app.boundx x+app.boundx x-app.boundx],...
                        [-50 -50 50 50], patchcol, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
                    hold off
                    app.isHover = true;
                    app.leg = text(x,55,msg,'HorizontalAlignment', 'center','BackgroundColor', [0.9 0.9 0.9], 'EdgeColor', [0.5 0.5 0.5]);
                
                case 'axis'
                    patchcol = [1 0 0];
                    msg = 'Drag to change axis limit';
                    
                    DrawRays(app);
                    hold on
                    app.lensBox = patch([xl(1) xl(2) xl(2) xl(1)],...
                        [yl(1) yl(1) yl(1)+0.1*(yl(2) - yl(1)) yl(1)+0.1*(yl(2) - yl(1))], patchcol, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
                    hold off
                    app.isHover = true;
                    app.leg = text(x,yl(1)+0.1*(yl(2) - yl(1)),msg,'HorizontalAlignment', 'center','BackgroundColor', [0.9 0.9 0.9], 'EdgeColor', [0.5 0.5 0.5]);
                    
                case 'none'
                    delete(app.lensBox)
                    delete(app.leg)
                    app.isHover = false;
                    title('')
            end
        end
        
        function buttonUp(app,~,~)
            title('')
            app.fig.WindowButtonMotionFcn = @app.hoverMotion;
            app.isDragging = false;
            app.isFocussing = false;
            app.isChangingAxis = false;
            app.currLens = [];
        end
        
        function addLens(app,~,~)
            title('Click to place lens')
            C = get (gca, 'CurrentPoint');
            x = C(1,1);
            app.Nlens = app.Nlens + 1;
            app.xpos(app.Nlens) = x;
            app.flength(app.Nlens) = 500;
            app.isDragging = true;
            app.currLens = app.Nlens;
            app.fig.WindowButtonMotionFcn = @app.mouseMotion;
        end
        
        function delLens(app,~,~)
            if(app.Nlens > 1)
                title('Select lens to remove')
                [x,y] = ginput(1);
                [offset, lens] = min(abs(x - app.xpos));
                if(offset < app.boundx)
                    app.Nlens = app.Nlens - 1;
                    app.xpos(lens) = [];
                    app.flength(lens) = [];
                    DrawRays(app);
                end
            else
                title('Cant remove last lens!');
            end
        end
        
        function toggleDrawDist(app,~,~)
           app.drawDist = ~app.drawDist;
           DrawRays(app);
        end
        
        function toggleDrawFlength(app,~,~)
           app.drawFlength = ~app.drawFlength;
           DrawRays(app);
        end
        
        function clickText(app,~,~)
           C = get (gca, 'CurrentPoint');
           x = C(1,1);
           y = C(1,2);

           if(y < 0)
              [offset, lens] = min(abs(x - app.xpos));
              answer = inputdlg('Set focal length', 'New focal length');
              if(~isempty(answer)), app.flength(lens) = str2num(answer{1}); end
           else
              offset = x - app.xpos;
              offset(offset < 0) = [];
              lens = length(offset) + 1;
              answer = inputdlg('Set separation', 'New separation');
              if(~isempty(answer))
                  answer = str2num(answer{1});
                  oldx = app.xpos(lens);
                  if(lens == 1)
                      oldsep = oldx;
                  else
                      oldsep = app.xpos(lens) - app.xpos(lens - 1);
                  end
                  
                  delta = answer - oldsep;
                  
                  app.xpos(lens:end) = app.xpos(lens:end) + delta;
              end
           end
           
           title('')
           app.fig.WindowButtonMotionFcn = @app.hoverMotion;
           app.isDragging = false;
           app.isFocussing = false;
           DrawRays(app);
           
        end
        
        function save(app,~,~)
           [fname, pathname] = uiputfile('*.mat', 'Save configuration file');
           warning ('off','all');
           save([pathname fname], 'app')
           warning ('on','all');
           title(['Saved as ' pathname fname])
        end
        
        function load(app,~,~)
           [fname pname] = uigetfile('*.mat', 'Load configuration file');
           close(app.fig)
           load([pname fname])
           DrawRays(app);
           title(['Loaded ' fname])
        end
        
        % Destructor
        function closeApp(app,~,~)
            delete(app.fig)
        end
        
    end
    
end