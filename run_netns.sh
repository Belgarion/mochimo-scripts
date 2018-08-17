#!/bin/sh

if [ -z $1 ]; then
	echo "Namespace name required"
	exit 1
fi
if [ -z $2 ]; then
	echo "IP required"
	exit 1
fi
NSNAME="$1"
IP=$2
CUDA_DEVICES="$3"

# Enable forwarding
sysctl -q net.ipv4.conf.all.forwarding=1

if ip netns list | grep -q "^${NSNAME}\\s"; then
	echo "Namespace $NSNAME already exists, recreating."

	# Stop old processes
	ip netns pids ${NSNAME} | xargs -rd'\n' kill
	sleep 5
	# Hard kill old processes
	ip netns pids ${NSNAME} | xargs -rd'\n' kill -9
	sleep 1

	ip netns del ${NSNAME}
fi

ip netns add ${NSNAME}

# Create veth link.
ip link add v-${NSNAME} type veth peer name vns-${NSNAME}

# Add peer-1 to NS.
ip link set vns-${NSNAME} netns ${NSNAME}


if ! brctl show | grep -q "^br-ns\\s"; then
	# bridge does not exist, create it
	brctl addbr br-ns
fi

if ! ip addr show br-ns | grep -q "inet 10.200.1.1/24"; then
	# ip does not exist on bridge, add it
	ip addr add 10.200.1.1/24 dev br-ns
fi

# Setup IP address of v-eth1.
ip link set v-${NSNAME} up
brctl addif br-ns v-${NSNAME}
ip link set br-ns up


# Setup IP address of v-peer1.
ip netns exec ${NSNAME} ip addr add ${IP}/24 dev vns-${NSNAME}
ip netns exec ${NSNAME} ip link set vns-${NSNAME} up
ip netns exec ${NSNAME} ip link set lo up
#
# Add default route
ip netns exec ${NSNAME} ip route add default via 10.200.1.1

# Copy datadir
#cp -a d d-${NSNAME}
mkdir -p d-${NSNAME}/bc

tmux has-session -t mochi || tmux -2 new-session -d -s mochi
tmux split-window -t mochi "ip netns exec ${NSNAME} ./run_gomochi.sh ${NSNAME} ${CUDA_DEVICES}"

tmux select-layout -t mochi tiled

