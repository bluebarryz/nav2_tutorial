# WATO Nav2

## How to run

- Run `./watod build localization` - Installs nav2, robot_localization, (turtlebot) gazebo - may take 20-30 mins to complete.
- Run `./watod up localization`
    - A small, transparent window will appear in the middle of the screen - this is for gazebo. It may take a few mins to fully load
- In a new terminal window, run:
    - `./watod -t localization` - This will "start bash shell in service localization".
    - `cd /opt/watonomous/`
    - `source setup.bash`
    - `ros2 launch nav2_gps_waypoint_follower_demo dual_ekf_navsat.launch.py`
- Open another new terminal and run:
    - `./watod -t localization`
    - `cd /opt/watonomous/`
    - `source setup.bash`
    - `ros2 launch nav2_gps_waypoint_follower_demo mapviz.launch.py`
