#include <linux/init.h>
#include <linux/module.h>
#include <stdarg.h>
#include <linux/kern_levels.h>
#include <linux/linkage.h>
#include <linux/cache.h>
#include <linux/printk.h>
#include <linux/kernel.h>	/* PRINTK */
#include <linux/types.h>	/* size_t */
#include <asm/types.h>	/* size_t */
#include <linux/version.h>
#include <linux/etherdevice.h>
#include <linux/ethtool.h>
#include <linux/proc_fs.h>
#include <linux/delay.h>
#include <linux/clk.h>
#include <linux/if_ether.h>
#include <linux/in6.h>
#include <linux/ip.h>
#include <linux/netdevice.h>
#include <linux/if_vlan.h>
#include <linux/rhashtable.h>
#include <linux/skbuff.h>
#include <linux/mlx5/driver.h>
#include <linux/mlx5/qp.h>
#include <linux/mlx5/cq.h>
#include <linux/mlx5/port.h>
#include <linux/mlx5/vport.h>
#include <linux/mlx5/transobj.h>
#include <net/sch_generic.h>
#include <net/ip.h>
#include <net/flow_dissector.h>
#include <net/pkt_cls.h>
#include <net/switchdev.h>
#include <net/rtnetlink.h>
#include <generated/utsrelease.h>
//Added to use IFLA flags
#include <linux/if_bridge.h>
#include <net/tc_act/tc_gact.h>
#include <net/tc_act/tc_skbedit.h>
#include <linux/mlx5/fs.h>
#include <linux/mlx5/device.h>
#include <net/tc_act/tc_mirred.h>
#include <net/tc_act/tc_vlan.h>
#include "/home/dccom/kernel/linux-4.9/drivers/net/ethernet/mellanox/mlx5/core/wq.h"
#include "/home/dccom/kernel/linux-4.9/drivers/net/ethernet/mellanox/mlx5/core/en.h"
#include "/home/dccom/kernel/linux-4.9/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h"
#include "/home/dccom/kernel/linux-4.9/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h"
#include "/home/dccom/kernel/linux-4.9/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h"
#include "/home/dccom/kernel/linux-4.9/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h"
#define ENABLE_2ND_NIC

struct port_info {
	char dev_name[33];
	int portid;
};
struct port_info ports[2];
#define DEV_NAME1 "ens1"
#define DEV_NAME2 "ens3"

#define PRINTK(fmt, arg...)  do { printk(KERN_ALERT fmt, ##arg); } while (0)

struct dp_swdev {
        struct notifier_block fib_nb;
};
struct swdev_info {
	struct net_device_ops new_netdev_ops;
	struct switchdev_ops  new_switchdev_ops;
	struct ethtool_ops new_ethtool_ops;

	struct net_device_ops *orig_netdev_ops;
	struct switchdev_ops  *orig_switchdev_ops;
	struct ethtool_ops *orig_ethtool_ops;
};

struct fl_flow_key {
	int	indev_ifindex;
	struct flow_dissector_key_control control;
	struct flow_dissector_key_basic basic;
	struct flow_dissector_key_eth_addrs eth;
	struct flow_dissector_key_addrs ipaddrs;
	union {
		struct flow_dissector_key_ipv4_addrs ipv4;
		struct flow_dissector_key_ipv6_addrs ipv6;
	};
	struct flow_dissector_key_ports tp;
} __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */

struct mlx5e_tc_flow {
	struct rhash_head	node;
	u64			cookie;
	struct mlx5_flow_rule	*rule;
	struct mlx5_esw_flow_attr *attr;
};

/*struct mlx5e_tc_table {
	struct mlx5_flow_table		*t;

	struct rhashtable_params        ht_params;
	struct rhashtable               ht;
};*/

struct pmac_port_info {
	struct swdev_info swdev;
};
static int print_obj(const struct switchdev_obj_port_vlan *vlan)
{
	struct net_device *lower_dev;
	struct list_head *iter;
	//PRINTK("VLAN begin:%d end:%d flag:%d\r\n",htons(vlan->vid_begin), htons(vlan->vid_end), vlan->flags);
	PRINTK("VLAN begin:%d end:%d flag:%d\r\n",vlan->vid_begin, vlan->vid_end, vlan->flags);
	if(vlan && vlan->obj.orig_dev) {
		struct net_device *tmp_dev;
		PRINTK("obj: orig_dev=%s\n", vlan->obj.orig_dev->name);
		tmp_dev = dev_get_by_name(&init_net, vlan->obj.orig_dev->name);
		if (tmp_dev) {
			if (is_vlan_dev(tmp_dev)) {
			    struct vlan_dev_priv *vlan = vlan_dev_priv(tmp_dev);
			    PRINTK("vlan->real_dev.name=%s vid=%d\n", vlan->real_dev->name, vlan->vlan_id);
			}
			dev_put(tmp_dev);
		}
	}

	netdev_for_each_lower_dev(vlan->obj.orig_dev, lower_dev, iter) {
		PRINTK("lower device=%s\n", lower_dev->name);
	}
    return 0;
}

struct pmac_port_info dp_port_info[2];
static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
	[IFLA_BRPORT_COST]	= { .type = NLA_U32 },
    };
static int print_nlmessage(struct net_device *dev, struct nlmsghdr *nlmsg)
{
    char *str;
	struct ifinfomsg *ifm;
        struct nlattr *br_spec, *attr;
        struct nlattr *protinfo,*ifname;
        int rem;
	int err = 0;
	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
    struct bridge_vlan_info *vinfo = NULL;
    PRINTK("print_nlmessage\r\n");
//    str = nlmsg_type_to_str(nlmsg->nlmsg_type);
    if(nlmsg != NULL) {
        ifm = nlmsg_data(nlmsg);
        PRINTK("ifinfo family:%d pad:%d type:%d index:%d flags:%d change:%d\r\n",ifm->ifi_family,  ifm->__ifi_pad, ifm->ifi_type, ifm->ifi_index,
                ifm->ifi_flags, ifm->ifi_change);
        PRINTK("nlmsg flags:%d (0x%03x)\r\n",nlmsg->nlmsg_flags,nlmsg->nlmsg_flags);
        PRINTK("Sequence number: %d (0x%08x)\r\n",
                nlmsg->nlmsg_seq, nlmsg->nlmsg_seq);
        PRINTK("len:%d TYPE:%d\r\n",nlmsg->nlmsg_len,nlmsg->nlmsg_type);
        br_spec = nlmsg_find_attr(nlmsg, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
        if (!br_spec) {
            return -EINVAL;
        } else {	
            nla_for_each_nested(attr, br_spec, rem) {
                int status;
                __u16 mode;
                PRINTK("attr type:%d nla len:%d\r\n", nla_type(attr), nla_len(attr));
                if (nla_type(attr) == IFLA_BRIDGE_FLAGS) {
                    //continue;
                    if (nla_len(attr) < sizeof(mode))
                        return -EINVAL;

                    mode = nla_get_u16(attr);
                    PRINTK("bridge mode:%d\r\n",mode);
                    //break;
                }
                if(nla_type(attr) == IFLA_IFNAME) {
                    PRINTK("bridge name:%s\r\n",(char *)nla_data(attr));
                }
                if(nla_type(attr) == IFLA_BRIDGE_VLAN_INFO) {
                    vinfo = nla_data(attr);
                    PRINTK("bridge vlan flags:%d vlan:%d\r\n",vinfo->flags,vinfo->vid);
                }
            }
        }
        //ifname = nlmsg_find_attr(nlmsg,sizeof(struct ifinfomsg), IFLA_IFNAME);
        //           PRINTK("bridge name:%s type:%d\r\n",nla_data(ifname),nla_type(ifname));
        protinfo = nlmsg_find_attr(nlmsg, sizeof(struct ifinfomsg), IFLA_PROTINFO);
        if (!protinfo) {
            PRINTK("no proto info\r\n");
            return -EINVAL;
        } else {
            if (protinfo->nla_type & NLA_F_NESTED) {
                err = nla_parse_nested(tb, IFLA_BRPORT_MAX,
                        protinfo, br_port_policy);
                if (err) {
                    PRINTK("nla parse nested error\r\n");
                    return err;
                }
                if (tb[IFLA_BRPORT_COST]) {
                    PRINTK("COST value:%d\r\n",nla_get_u32(tb[IFLA_BRPORT_COST]));
                }
            }
        }
    }
else {
    PRINTK("nlmessage is NULL\r\n");
    }
    return 0;
}

static int dp_swdev_port_get_phys_port_name(struct net_device *dev,
					  char *buf, size_t len)
{
	int i;

	for (i=0; i<sizeof(ports)/sizeof(ports[0]); i++) {
		if(strcmp(dev->name, ports[i].dev_name) == 0) {
			if (snprintf(buf, len, "p%d", ports[i].portid) >= len)
				return -EINVAL;
			//PRINTK("dp_swdev_port_get_phys_port_name ok:%s(p%d)\r\n", dev->name, ports[i].portid);
			return 0;
		}
	}
	PRINTK("dp_swdev_port_get_phys_port_name failed:%s ??)\r\n", dev->name);
 	return 0;

}

static int dp_swdev_port_change_proto_down(struct net_device *dev,
					 bool proto_down)
{
	//struct dp_swdev_port *dp_swdev_port = netdev_priv(dev);
	PRINTK("dp_swdev_port_change_proto_down\r\n");
	//if (dp_swdev_port->dev->flags & IFF_UP)
	//	dp_swdev_port_set_enable(dp_swdev_port, !proto_down);
	//dp_swdev_port->dev->proto_down = proto_down;
	return 0;
}

static void dp_swdev_port_neigh_destroy(struct net_device *dev,
				      struct neighbour *n)
{
	PRINTK("dp_swdev_port_neigh_destroy\r\n");
	
	//err = dp_swdev_world_port_neigh_destroy(dp_swdev_port, n);
	//if (err)
	//	netdev_warn(dp_swdev_port->dev, "failed to handle neigh destroy (err %d)\n",
	//		    err);
}
char GSWIP_ID[ETH_ALEN]={'0', '0', '1', '1', '1', '1'};
void print_attr_id(int id)
{
	if( id == SWITCHDEV_ATTR_ID_UNDEFINED) 
		PRINTK("SWITCHDEV_ATTR_ID_UNDEFINED\n");
	else if (id == SWITCHDEV_ATTR_ID_PORT_PARENT_ID) 
		PRINTK("SWITCHDEV_ATTR_ID_PORT_PARENT_ID\n");
	else if (id == SWITCHDEV_ATTR_ID_PORT_STP_STATE)
		PRINTK("SWITCHDEV_ATTR_ID_PORT_STP_STATE\n");
	else if (id == SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS)
		PRINTK("SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS\n");
	else if (id == SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME)
		PRINTK("SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME\n");
	else if (id == SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING)
		PRINTK("SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING\n");
	else 
		PRINTK("unknow ID:%d\n", id);
}

void print_attr(const struct switchdev_attr *attr, struct net_device *dev)
{
	print_attr_id(attr->id);
	PRINTK("devname:%s ppid:%s ppid_len:%d orig dev name:%s\r\n", dev->name,(char *)attr->u.ppid.id,attr->u.ppid.id_len,attr->orig_dev->name);

    if (is_vlan_dev(attr->orig_dev)) {
        PRINTK("=========orig VLAN ID:%d\r\n",vlan_dev_vlan_id(attr->orig_dev));
    }
    if (is_vlan_dev(dev)) {
        PRINTK("=========dev vlan:%d\r\n",vlan_dev_vlan_id(dev));
    }

}

void print_obj_id(int id)
{
	if( id == SWITCHDEV_OBJ_ID_UNDEFINED) 
		PRINTK("SWITCHDEV_OBJ_ID_UNDEFINED\n");
	else if (id == SWITCHDEV_OBJ_ID_PORT_VLAN) 
		PRINTK("SWITCHDEV_OBJ_ID_PORT_VLAN\n");
	else if (id == SWITCHDEV_OBJ_ID_PORT_FDB)
		PRINTK("SWITCHDEV_OBJ_ID_PORT_FDB\n");
	else if (id == SWITCHDEV_OBJ_ID_PORT_MDB)
		PRINTK("SWITCHDEV_OBJ_ID_PORT_MDB\n");
	else 
		PRINTK("unknow ID:%d\n", id);
}

static int dp_swdev_port_attr_get(struct net_device *dev,
				struct switchdev_attr *attr)
{	
	int err = 0;
		        
	switch (attr->id) {
	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
		attr->u.ppid.id_len = ETH_ALEN;
		ether_addr_copy(attr->u.ppid.id, GSWIP_ID);
		break;
	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
		//err = dp_swdev_world_port_attr_bridge_flags_get(dp_swdev_port,
		//					      &attr->u.brport_flags);
		break;
	default:
		PRINTK("dp_swdev_port_attr_get:\n");
		print_attr(attr, dev);
		return -EOPNOTSUPP;
	}

        
        return err;
}

static int dp_swdev_port_attr_set(struct net_device *dev,
				const struct switchdev_attr *attr,
				struct switchdev_trans *trans)
{
    int err = 0;
    PRINTK("dp_swdev_port_attr_set:\n");
    print_attr(attr, dev);
    if( netif_is_bridge_port(dev)) {
        PRINTK("dp_swdev_port_attr_set attr bridge port\r\n");
    }
    PRINTK("dp_swdev_port_attr_set attr id:%d devname:%s ppid:%s ppid_len:%d orig dev name:%s\r\n",attr->id,dev->name,(char *)attr->u.ppid.id,attr->u.ppid.id_len,attr->orig_dev->name);
    print_attr_id(attr->id);
    if(trans->ph_prepare == 1)
    {
        PRINTK("%s ph->prepare:%d\r\n",__func__,trans->ph_prepare);
    }
#if 1
    switch (attr->id) { 
        case SWITCHDEV_ATTR_ID_PORT_STP_STATE:

            PRINTK("dp_swdev_port_attr_set attr state:%d ppid:%s ppid_len:%d orig dev name:%s\r\n",attr->u.stp_state,(char *)attr->u.ppid.id,attr->u.ppid.id_len,attr->orig_dev->name);
            //err = dp_swdev_world_port_attr_stp_state_set(dp_swdev_port,
            //					   attr->u.stp_state,
            //					   trans);
            break;
        case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
            PRINTK("dp_swdev_port_attr_set port bridge:%ul\r\n",(unsigned int)(attr->u.brport_flags));
            //err = dp_swdev_world_port_attr_bridge_flags_set(dp_swdev_port,
            //					      attr->u.brport_flags,
            //					      trans);
            break;
        case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
            PRINTK("dp_swdev_port_attr_set aging:%lu\r\n",attr->u.ageing_time);
            //err = dp_swdev_world_port_attr_bridge_ageing_time_set(dp_swdev_port,
            //						    attr->u.ageing_time,
            //						    trans);
            break; 
        default:
            err = -EOPNOTSUPP;
            break;
    }

#endif
    return err;
}

static int dp_swdev_port_obj_add(struct net_device *dev,
			       const struct switchdev_obj *obj,
			       struct switchdev_trans *trans)
{	
    int err = 0;
    struct vlan_vid_info *vid_info;

    PRINTK("dp_swdev_port_obj_add id:%d flags:%d dev name:%s\r\n",obj->id, obj->flags,dev->name);
    //list_for_each_entry(vid_info, dev->vlan_info->vid_list, list)
//	PRINTK("vid_info: vid=%d prot=%x\n", vid_info->vid, vid_info->proto);
    {
	    struct net_device *ret = vlan_dev_priv(dev)->real_dev;
    
	    while (ret && is_vlan_dev(ret)) {
	    	PRINTK("ret->name=%s\n", ret->name);
		    ret = vlan_dev_priv(ret)->real_dev;
	    }
    }

    print_obj_id(obj->id);

    if( netif_is_bridge_port(dev)) {
        PRINTK("dp_swdev_port_obj_add attr bridge port\r\n");
    }
    if(trans->ph_prepare == 1)
    {
        PRINTK("%s ph->prepare:%d\r\n",__func__,trans->ph_prepare);
    }
    switch (obj->id) {
        case SWITCHDEV_OBJ_ID_PORT_VLAN:
            print_obj(SWITCHDEV_OBJ_PORT_VLAN(obj));
            break;
        case SWITCHDEV_OBJ_ID_PORT_FDB:
            /*		err = rocker_world_port_obj_fdb_add(rocker_port,
                    SWITCHDEV_OBJ_PORT_FDB(obj),
                    trans);*/
            break;
        default:
            err = -EOPNOTSUPP;
            break;
    }
    return err;
}

static int dp_swdev_port_obj_del(struct net_device *dev,
			       const struct switchdev_obj *obj)
{
	int err = 0;

	PRINTK("dp_swdev_port_obj_del\r\n");
	print_obj_id(obj->id);
    switch (obj->id) {
	case SWITCHDEV_OBJ_ID_PORT_VLAN:
         print_obj(SWITCHDEV_OBJ_PORT_VLAN(obj));
		break;
	default:
		err = -EOPNOTSUPP;
		break;
	}
	
	return err;
}

static int dp_swdev_port_obj_dump(struct net_device *dev,
				struct switchdev_obj *obj,
				switchdev_obj_dump_cb_t *cb)
{
	int err = 0;
	PRINTK("dp_swdev_port_obj_dump: %s\r\n", dev->name);
	return err;
}

static int dp_swdev_port_bridge_getlink(struct sk_buff *skb, u32 pid,
					    u32 seq, struct net_device *dev,
					    u32 filter_mask, int nlflags)
{
	PRINTK("dp_swdev_port_bridge_getlink:%s\r\n", dev->name);
	return switchdev_port_bridge_getlink(skb, pid, seq, dev, filter_mask, nlflags);
}

static inline int dp_swdev_port_bridge_setlink(struct net_device *dev,
						struct nlmsghdr *nlh,
						u16 flags)
{
	PRINTK("dp_swdev_port_bridge_setlink\r\n");
        print_nlmessage(dev,nlh);
        //PRINTK("setlink :msg data %s dev name:%s\r\r",*((int *)NLMSG_DATA(nlh)),dev->name);
	//return switchdev_port_bridge_setlink(dev, nlh, flags);
        return 0;
}

static inline int dp_swdev_port_bridge_dellink(struct net_device *dev,
						struct nlmsghdr *nlh,
						u16 flags)
{
	PRINTK("dp_swdev_port_bridge_dellink\r\n");
	//return switchdev_port_bridge_dellink(dev, nlh, flags);
        return 0;
}

static inline int dp_swdev_vlan_rx_add(struct net_device *dev,
					__be16 proto, u16 vid)
{	
	struct net_device *lower_dev;
	struct list_head *iter;
	PRINTK("dp_swdev_vlan_rx_add: %s vid %d proto=%x\r\n", dev->name, vid, proto);
	//return switchdev_port_bridge_dellink(dev, nlh, flags);
	netdev_for_each_lower_dev(dev, lower_dev, iter) {
		PRINTK("lower device=%s\n", lower_dev->name);
	}
	return 0;
}

static inline int dp_swdev_vlan_rx_kill(struct net_device *dev,
                        __be16 proto, u16 vid)
{
	PRINTK("dp_swdev_vlan_rx_kill \r\n");
	//return switchdev_port_bridge_dellink(dev, nlh, flags);
        return 0;
}

static inline int dp_swdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
					 struct net_device *dev,
					 const unsigned char *addr,
					 u16 vid, u16 nlm_flags)
{
	PRINTK("dp_swdev_port_fdb_add\r\n");
	//return switchdev_port_fdb_add(ndm, tb, dev, addr, vid, nlm_flags);
        return 0;
}

static inline int dp_swdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
					 struct net_device *dev,
					 const unsigned char *addr, u16 vid)
{
	PRINTK("switchdev_port_fdb_del\r\n");
	//return switchdev_port_fdb_del(ndm, tb, dev, addr, vid);
        return 0;
}

static inline int dp_swdev_port_fdb_dump(struct sk_buff *skb,
					  struct netlink_callback *cb,
					  struct net_device *dev,
					  struct net_device *filter_dev,
					  int *idx)
{
	PRINTK("dp_swdev_port_fdb_dump\r\n");
    return switchdev_port_fdb_dump(skb, cb, dev, filter_dev, idx);
}

static int dp_swdev_router_fib_event(struct notifier_block *nb,
				   unsigned long event, void *ptr)
{
	int err;

	PRINTK("dp_swdev_router_fib_event\r\n");
	switch (event) {
	case FIB_EVENT_ENTRY_ADD:
                PRINTK("dp_swdev_router_fib_event FIB_EVENT_ENTRY_ADD \r\n");
		break;
	case FIB_EVENT_ENTRY_DEL:
                PRINTK("dp_swdev_router_fib_event FIB_EVENT_ENTRY_DEL \r\n");
		break;
	case FIB_EVENT_RULE_ADD: /* fall through */
	case FIB_EVENT_RULE_DEL:
                PRINTK("dp_swdev_router_fib_event FIB_EVENT_RULE_DEL \r\n");
		break;
	}
	return NOTIFY_DONE;
}

static int show_fl_destroy(struct mlx5e_priv *priv,
			struct tc_cls_flower_offload *f)
{
	struct mlx5e_tc_flow *flow;
	struct mlx5e_tc_table *tc = &priv->fs.tc;

	printk("<<<<<<<<<first111111>>>>>>>>>>>>");
	flow = rhashtable_lookup_fast(&tc->ht, &f->cookie,
				      tc->ht_params);

	printk("<<<<<<<<<second111111>>>>>>>>>>>>");
	if ((flow) && (flow!=NULL)) {
		printk("flow:: %x\n",&(flow));
		printk("<<<<<<<<<111111>>>>>>>>>>>>");
		if((flow->rule) && (flow->rule != NULL)) {
		        printk("flow->rule :: %x\n",flow->rule);
		}
		printk("<<<<<<<<<222222>>>>>>>>>>>>");
		if((flow->attr) && (flow->attr != NULL)) {
		        printk("flow->attr :: %x\n",flow->attr);
		}
	}
	return 0;
}

int dp_ndo_setup_tc(struct net_device *dev,
	u32 handle,
	__be16 protocol,
	struct tc_to_netdev *tc)
{
	//struct fl_flow_key *k = (struct fl_flow_key *) tc->cls_flower->key;
	struct tc_cls_flower_offload *f = (struct tc_cls_flower_offload *) tc->cls_flower;
	struct mlx5e_priv *priv = netdev_priv(dev);
	u16 addr_type = 0;
	u32 flags = 0;
	u16 thoff = 0;
	u8 ip_proto = 0;

	printk("protoco=%d 0x%x \n", protocol, protocol);
	if (tc) {
		if (tc->type == TC_SETUP_MQPRIO)
			printk("tc->type=%d (TC_SETUP_MQPRIO)\n", tc->type);
		else if (tc->type == TC_SETUP_CLSU32)
			printk("tc->type=%d (TC_SETUP_CLSU32)\n", tc->type);
		else if (tc->type == TC_SETUP_CLSFLOWER)
		{
			printk("tc->type=%d (TC_SETUP_CLSFLOWER)\n", tc->type);
			if (tc->cls_flower->command == TC_CLSFLOWER_REPLACE) {
				printk("tc->cls_flower.command :: %x {TC_CLSFLOWER_REPLACE}\n",tc->cls_flower->command);
			} else if (tc->cls_flower->command == TC_CLSFLOWER_DESTROY) {
				printk("tc->cls_flower.command :: %x {TC_CLSFLOWER_DESTROY}\n",tc->cls_flower->command);
				show_fl_destroy(priv, tc->cls_flower);
			} else if (tc->cls_flower->command == TC_CLSFLOWER_STATS) {
				printk("tc->cls_flower.command :: %x {TC_CLSFLOWER_STATS}\n",tc->cls_flower->command);
			}
			if(((tc) && (tc != NULL)) && ((tc->cls_flower) && (tc->cls_flower != NULL)) && ((tc->cls_flower->dissector) && (tc->cls_flower->dissector != NULL))) {
				printk("tc->cls_flower.dissector :: %pr\n", &(tc->cls_flower->dissector));
				if((tc->cls_flower->dissector->used_keys) && (tc->cls_flower->dissector->used_keys != NULL)) {
					printk("tc->cls_flower->dissector->used_keys :: %u\n",tc->cls_flower->dissector->used_keys);
				}
			}
			if((tc->cls_flower->cookie) && (tc->cls_flower->cookie != NULL)) {
				printk("tc->cls_flower->cookie :: %lu\n", tc->cls_flower->cookie);
			}
			if((tc->cls_flower->key) && (tc->cls_flower->key != NULL)) {
				printk("tc->cls_flower->key->control->addr_type :: %x\n", tc->cls_flower->key->control.addr_type);
				//printk("tc->cls_flower->key->basic->ip_proto :: %ph\n", &(tc->cls_flower->key->basic.ip_proto));
			}
			if((tc->cls_flower->exts) && (tc->cls_flower->exts != NULL)){
				printk("tc->cls_flower->exts.actions :: %x\n",tc->cls_flower->exts->action);
			}
			if(((f->dissector) && (f->dissector != NULL)) && ((f->dissector->used_keys) && (f->dissector->used_keys != NULL)))
			{
				if (f->dissector->used_keys &
				    ~(BIT(FLOW_DISSECTOR_KEY_CONTROL) |
				      BIT(FLOW_DISSECTOR_KEY_BASIC) |
				      BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) |
				      BIT(FLOW_DISSECTOR_KEY_VLAN) |
				      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
				      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
				      BIT(FLOW_DISSECTOR_KEY_PORTS))) {
					netdev_warn(priv->netdev, "Unsupported key used: 0x%x\n",
						    f->dissector->used_keys);
					return -EOPNOTSUPP;
				}

				if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_CONTROL)) {
					struct flow_dissector_key_control *key =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_CONTROL,
									  f->key);
					if((key) && (key != NULL)) {
						addr_type = key->addr_type;
						if (addr_type == 2) {
							printk("offload_key->CONTROL_addr_type :: %x {_KEY_IPV4_ADDRS}\n", addr_type);
						} else if (addr_type == 3) {
                                                        printk("offload_key->CONTROL_addr_type :: %x {_KEY_IPV6_ADDRS}\n", addr_type);
                                                } else {
                                                        printk("offload_key->CONTROL_addr_type :: %x {_Undefined_}\n", addr_type);
                                                }
					}
				}

				if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_BASIC)) {
					struct flow_dissector_key_basic *key =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_BASIC,
									  f->key);
					struct flow_dissector_key_basic *mask =
						skb_flow_dissector_target(f->dissector,
							  FLOW_DISSECTOR_KEY_BASIC,
									  f->mask);
					if(((key) && (key != NULL)) && ((mask) && (mask != NULL))) {
						ip_proto = key->ip_proto;
						if (key->n_proto == 0x8) {
							printk("offload_key->eth_type / mask :: %2ph { IPv4 } / %2ph\n", &(key->n_proto), &(mask->n_proto));
						} else if (key->n_proto == 0xdd86) {
                                                        printk("offload_key->eth_type / mask :: %2ph { IPv6 } / %2ph\n", &(key->n_proto), &(mask->n_proto));
                                                } else {
                                                        printk("offload_key->eth_type / mask :: %2ph {_Undefined_} / %2ph\n", &(key->n_proto), &(mask->n_proto));
                                                }
						if (key->ip_proto == 0x06) {
							printk("offload_key->ip_proto / mask :: %ph {_TCP_} / %ph\n", &(ip_proto), &(mask->ip_proto));
						} else if (key->ip_proto == 0x11) {
							printk("offload_key->ip_proto / mask :: %ph {_UDP_} / %ph\n", &(ip_proto), &(mask->ip_proto));
						} else {
							printk("offload_key->ip_proto / mask :: %ph {_Undefined_} / %ph\n", &(ip_proto), &(mask->ip_proto));
                                                }
						//printk("offload_key->ip_proto :: %ph\n", &(ip_proto));
						//printk("f->dissector :: %16ph\n",dd &(f->dissector));
						//printk("f->mask :: %16ph\n", &(f->mask));
					}
					/*if((mask) && (mask != NULL)) {
						ip_proto = mask->ip_proto;
						printk("offload_mask->eth_type :: %2ph\n", &(mask->n_proto));
						printk("offload_mask->ip_proto :: %ph\n", &(ip_proto));
					}*/
				}
				if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
					struct flow_dissector_key_eth_addrs *key =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_ETH_ADDRS,
									  f->key);
					struct flow_dissector_key_eth_addrs *mask =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_ETH_ADDRS,
									  f->mask);
					if(((key) && (key != NULL)) && ((mask) && (mask != NULL))) {
						printk("offload_key->DST_MAC / MASK :: %pM / %pM\n", &(key->dst), &(mask->dst));
						printk("offload_key->SRC_MAC / MASK :: %pM / %pM\n", &(key->src), &(mask->src));
					}
					/*if((mask) && (mask != NULL)) {
						printk("offload_key->dst_mask :: %pM\n", &(mask->dst));
						printk("offload_key->src_mask :: %pM\n", &(mask->src));
					}*/
				}
				if (addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
					struct flow_dissector_key_ipv4_addrs *key =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
									  f->key);
					struct flow_dissector_key_ipv4_addrs *mask =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
									  f->mask);
					if(((key) && (key != NULL)) && ((mask) && (mask != NULL))) {
						printk("offload_key->src_ip / mask :: %pI4 / %pI4\n", &(key->src), &(mask->src));
						printk("offload_key->dst_ip / mask :: %pI4 / %pI4\n", &(key->dst), &(mask->dst));
					}
					/*if((mask) && (mask != NULL)) {
						printk("offload_key->src_mask :: %pI4\n", &(mask->src));
						printk("offload_key->dst_mask :: %pI4\n", &(mask->dst));
					}*/
				}
				if (addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
					struct flow_dissector_key_ipv6_addrs *key =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
									  f->key);
					struct flow_dissector_key_ipv6_addrs *mask =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
									  f->mask);

                                        if(((key) && (key != NULL)) && ((mask) && (mask != NULL))) {
                                                printk("offload_key->src_ipv6 / mask :: %pI6 / %pI6\n", &(key->src), &(mask->src));
                                                printk("offload_key->dst_ipv6 / mask :: %pI6 / %pI6\n", &(key->dst), &(mask->dst));
                                        }

				}
				if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_PORTS)) {
					struct flow_dissector_key_ports *key =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_PORTS,
									  f->key);
					struct flow_dissector_key_ports *mask =
						skb_flow_dissector_target(f->dissector,
									  FLOW_DISSECTOR_KEY_PORTS,
									  f->mask);
						switch (ip_proto) {
						case IPPROTO_TCP:
		                                        if(((key) && (key != NULL)) && ((mask) && (mask != NULL))) {
	        	                                        printk("offload_key->DST_Port / Mask :: %ph / %ph\n", &(key->dst), &(mask->dst));
	                	                                printk("offload_key->SRC_Port / Mask :: %ph / %ph\n", &(key->src), &(mask->src));
		                                        }
							break;

						case IPPROTO_UDP:
		                                        if(((key) && (key != NULL)) && ((mask) && (mask != NULL))) {
                		                                printk("offload_key->DST_Port / Mask :: %ph / %ph\n", &(key->dst), &(mask->dst));
		                                                printk("offload_key->SRC_Port / Mask :: %ph / %ph\n", &(key->src), &(mask->src));
                		                        }
							break;
						default:
							netdev_err(priv->netdev,
							   "Only UDP and TCP transport are supported\n");
							return -EINVAL;
						}
				}
			}
			/*if (tc->cls_flower->command == TC_CLSFLOWER_DESTROY) {
				struct mlx5e_tc_flow *flow;
				struct mlx5e_tc_table *tc = &priv->fs.tc;
				
				flow = rhashtable_lookup_fast(&tc->ht, &f->cookie,
							      tc->ht_params);
				if (flow){
				if((flow->rule) && (flow->rule != NULL)) {
					printk("flow->rule :: %ph\n",&(flow->rule));
				}
				if((flow->attr) && (flow->attr != NULL)) {
					printk("flow->attr :: %ph\n",&(flow->attr));
				}
				}
			}*/

		}
		else if (tc->type == TC_SETUP_MATCHALL)
			printk("tc->type=%d (TC_SETUP_MATCHALL)\n", tc->type);
		else if (tc->type == TC_SETUP_CLSBPF)
			printk("tc->type=%d (TC_SETUP_CLSBPF)\n", tc->type);
		else 
			printk("tc->type=%d (Undefiend)\n", tc->type);
	}
	
	
	
	return 0;
}

int register_swdev_callback(struct net_device *dev, struct swdev_info *swdev,  int flag)
{
struct dp_swdev *dp_swdev;
	dp_swdev = kzalloc(sizeof(*dp_swdev), GFP_KERNEL);
	if (!dp_swdev) {
                PRINTK("sp_swdev memory alloc fail \r\n");
		return -ENOMEM;
            }
	if (!swdev)
		return -1;
	//PRINTK("Addr of netdevops in datapath register:%p setlink addr:%p getlink:%p\r\n",dev->netdev_ops,dev->netdev_ops->ndo_bridge_setlink,dev->netdev_ops->ndo_bridge_getlink);
	if (flag) { /*register hook*/
		memset(swdev, 0, sizeof(*swdev));
		if (dev->netdev_ops) 
			memcpy(&swdev->new_netdev_ops, dev->netdev_ops, sizeof(struct net_device_ops));
		if (dev->switchdev_ops)
			memcpy(&swdev->new_switchdev_ops, dev->switchdev_ops, sizeof(struct switchdev_ops));
		if (dev->ethtool_ops)
			memcpy(&swdev->new_ethtool_ops, dev->ethtool_ops, sizeof(struct ethtool_ops));
	
		swdev->new_netdev_ops.ndo_bridge_getlink = dp_swdev_port_bridge_getlink; //rtnlink interface via ip/tc/bridge
		swdev->new_netdev_ops.ndo_bridge_setlink = dp_swdev_port_bridge_setlink; //rtnlink interface:
		swdev->new_netdev_ops.ndo_bridge_dellink = dp_swdev_port_bridge_dellink; //rtnlink interface:
		swdev->new_netdev_ops.ndo_vlan_rx_add_vid = dp_swdev_vlan_rx_add; //rtnlink interface:
		swdev->new_netdev_ops.ndo_vlan_rx_kill_vid = dp_swdev_vlan_rx_kill; //rtnlink interface:
		swdev->new_netdev_ops.ndo_setup_tc = dp_ndo_setup_tc;

		swdev->new_netdev_ops.ndo_fdb_add = dp_swdev_port_fdb_add;       //rtnlink interface: Add static FDB (MAC/VLAN) entry to port
		swdev->new_netdev_ops.ndo_fdb_del = dp_swdev_port_fdb_del;       //rtnlink interface: Del static FDB (MAC/VLAN) entry to port
		swdev->new_netdev_ops.ndo_fdb_dump = dp_swdev_port_fdb_dump;      //rtnlink interface: Dump port FDB (MAC/VLAN) entries

#if 1
		swdev->new_netdev_ops.ndo_get_phys_port_name = dp_swdev_port_get_phys_port_name; //??
		swdev->new_netdev_ops.ndo_change_proto_down = dp_swdev_port_change_proto_down;  //??
		swdev->new_netdev_ops.ndo_neigh_destroy = dp_swdev_port_neigh_destroy;          //?? for L3 acceleration ?

#endif
		swdev->new_switchdev_ops.switchdev_port_attr_get = dp_swdev_port_attr_get; //SWITCHDEV_ATTR_ID_PORT_PARENT_ID/STP_STATE/BRIDGE_FLAGS/BRIDGE_AGEING_TIME/BRIDGE_VLAN_FILTERING
		swdev->new_switchdev_ops.switchdev_port_attr_set = dp_swdev_port_attr_set;  //set bridge/stp
		swdev->new_switchdev_ops.switchdev_port_obj_add = dp_swdev_port_obj_add;   //add vlan(SWITCHDEV_OBJ_ID_PORT_VLAN)/fdb(SWITCHDEV_OBJ_ID_PORT_FDB)/mdb(SWITCHDEV_OBJ_ID_PORT_MDB)
		swdev->new_switchdev_ops.switchdev_port_obj_del = dp_swdev_port_obj_del;   //del vlan/fdb
		swdev->new_switchdev_ops.switchdev_port_obj_dump = dp_swdev_port_obj_dump;

		swdev->orig_netdev_ops =(struct net_device_ops *) dev->netdev_ops;
		swdev->orig_switchdev_ops = (struct switchdev_ops *)dev->switchdev_ops;
		swdev->orig_ethtool_ops = (struct ethtool_ops *)dev->ethtool_ops;
		
		dev->netdev_ops = (const struct net_device_ops *)&swdev->new_netdev_ops;
		dev->switchdev_ops =(const struct switchdev_ops *)&swdev->new_switchdev_ops;
		dev->ethtool_ops =(const struct ethtool_ops *)&swdev->new_ethtool_ops;

	dp_swdev->fib_nb.notifier_call = dp_swdev_router_fib_event;
	register_fib_notifier(&dp_swdev->fib_nb);
		//dev->ethtool_ops
	} else { /*unregister hook */
		dev->netdev_ops = (const struct net_device_ops *)swdev->orig_netdev_ops;
		dev->switchdev_ops = (const struct switchdev_ops *)swdev->orig_switchdev_ops;
		dev->ethtool_ops = (const struct ethtool_ops *)swdev->orig_ethtool_ops;
	}
	return 0;
}


static __init int dp_swdev_init_module(void)
{
	struct net_device *dev;
	char *dev_name;
	char ret = 0;
	int i;
	
	dev_name = DEV_NAME1;
	strcpy(ports[0].dev_name, dev_name);
	ports[0].portid = 1;
	dev = dev_get_by_name(&init_net, dev_name);
	if(dev) {
		ret = register_swdev_callback(dev, &dp_port_info[0].swdev, 1);
		dev_put(dev);
		PRINTK("hooked %s ok\n", dev_name);
	}
	else {
		PRINTK("cannot find dev %s\n", dev_name);
		ret = 1;
	}
	dev->features |= NETIF_F_HW_TC;
#ifdef ENABLE_2ND_NIC
	dev_name = DEV_NAME2;
	strcpy(ports[1].dev_name, dev_name);
	ports[1].portid = 2;
	dev = dev_get_by_name(&init_net, dev_name);

	dev = dev_get_by_name(&init_net, dev_name);
	if(dev) {
		ret = register_swdev_callback(dev, &dp_port_info[1].swdev, 1);
		dev_put(dev);
		PRINTK("hooked %s ok\n", dev_name);
	}
	else {
		PRINTK("cannot find dev %s\n", dev_name);
		ret = 1;
	}
	dev->features |= NETIF_F_HW_TC;
#endif
	for (i=0; i<sizeof(ports)/sizeof(ports[0]); i++) 
		PRINTK("registered p%d: %s\n", ports[i].portid, ports[i].dev_name);
	PRINTK("dp_swdev_init_module\n");
	
	
	return 0;
}

static __exit void dp_swdev_cleanup_module(void)
{
	struct net_device *dev;
	char *dev_name;
struct dp_swdev *dp_swdev;
	
	
	dev_name = DEV_NAME1;
	dev = dev_get_by_name(&init_net, dev_name);
	if(dev) {
                dp_swdev = dev_get_drvdata(&dev->dev);
	        unregister_fib_notifier(&dp_swdev->fib_nb);
                kfree(dp_swdev);	
		register_swdev_callback(dev, &dp_port_info[0].swdev, 0);
		dev_put(dev);
	}
#ifdef ENABLE_2ND_NIC
	dev_name = DEV_NAME2;
	dev = dev_get_by_name(&init_net, dev_name);
	if(dev) {
                dp_swdev = dev_get_drvdata(&dev->dev);
	        unregister_fib_notifier(&dp_swdev->fib_nb);
                kfree(dp_swdev);	
		register_swdev_callback(dev, &dp_port_info[1].swdev, 0);
		dev_put(dev);
	}
#endif
	PRINTK("dp_swdev_cleanup_module\n");
}



module_init(dp_swdev_init_module);
module_exit(dp_swdev_cleanup_module);
MODULE_LICENSE("GPL");

