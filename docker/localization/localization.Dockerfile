ARG BASE_IMAGE=ghcr.io/watonomous/robot_base/base:humble-ubuntu22.04
################################ Source ################################
FROM ${BASE_IMAGE} AS source
WORKDIR ${AMENT_WS}/src
COPY src/localization nav2_gps_waypoint_follower_demo
# Scan for rosdeps
RUN apt-get -qq update && rosdep update && \
    rosdep install --from-paths . --ignore-src -r -s \
    | grep 'apt-get install' \
    | awk '{print $3}' \
    | sort > /tmp/colcon_install_list

################################# Dependencies ################################
FROM ${BASE_IMAGE} AS dependencies
# Install specific dependencies
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-robot-localization \
    ros-${ROS_DISTRO}-mapviz \
    ros-${ROS_DISTRO}-mapviz-plugins \
    ros-${ROS_DISTRO}-tile-map \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-turtlebot3-gazebo \ 
    ros-${ROS_DISTRO}-teleop-twist-keyboard

# Install Rosdep requirements
COPY --from=source /tmp/colcon_install_list /tmp/colcon_install_list
RUN apt-fast install -qq -y --no-install-recommends $(cat /tmp/colcon_install_list)

# Copy in source code from source stage
WORKDIR ${AMENT_WS}
COPY --from=source ${AMENT_WS}/src src

# Dependency Cleanup
WORKDIR /
RUN apt-get -qq autoremove -y && apt-get -qq autoclean && apt-get -qq clean && \
    rm -rf /root/* /root/.ros /tmp/* /var/lib/apt/lists/* /usr/share/doc/*

################################ Build ################################
FROM dependencies AS build
# Build ROS2 packages
WORKDIR ${AMENT_WS}
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build \
    --cmake-args -DCMAKE_BUILD_TYPE=Release --install-base ${WATONOMOUS_INSTALL}

# Source and Build Artifact Cleanup
RUN rm -rf src/* build/* devel/* install/* log/*

# Entrypoint will run before any CMD on launch
COPY docker/wato_ros_entrypoint.sh ${AMENT_WS}/wato_ros_entrypoint.sh
ENTRYPOINT ["./wato_ros_entrypoint.sh"]