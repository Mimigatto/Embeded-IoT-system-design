% Parameters 

g = 9.81;  % gravitational acceleration (m/s^2) 

k = 0.8;   % coefficient of restitution 

h = 1;     % initial height (m) 

v = 0;     % initial velocity (m/s) 

dt = 0.01; % time step (s) 

t_max = 3; % total simulation time (s) 

 % Time vector 

time = 0:dt:t_max; 

  

% Initialize arrays for height and velocity 

height = zeros(size(time)); 

velocity = zeros(size(time)); 

 % Initial conditions 

height(1) = h; 

velocity(1) = v; 

 % Simulation loop 

for i = 2:length(time) 

    if height(i-1) > 0 || velocity(i-1) ~= 0 

        % Update velocity in the air 

        velocity(i) = velocity(i-1) - g*dt; 

        % Update height 

        height(i) = height(i-1) + velocity(i-1)*dt - 0.5*g*dt^2;         

        % Check for collision with the ground 

        if height(i) < 0 

            % Correct the height 

            height(i) = 0; 

            % Invert and reduce the velocity with restitution 

            velocity(i) = -velocity(i) * k; 

        end 

    else 

        % Ball has come to rest 

        velocity(i) = 0; 

        height(i) = 0; 

    end 

end 

% Plot the results 

figure; 

plot(time, height, 'LineWidth', 1.5); 

xlabel('Time (s)'); 

ylabel('Height (m)'); 

title('Bouncing Ball Height Over Time'); 

grid on; 

  

% Optional: Plot velocity over time 

figure; 

plot(time, velocity, 'LineWidth', 1.5); 

xlabel('Time (s)'); 

ylabel('Velocity (m/s)'); 

title('Bouncing Ball Velocity Over Time'); 

grid on; 