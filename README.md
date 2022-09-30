# group 1
4 0 * * * /scripts/simulate_agent.sh login 1 &> /var/log/agent_error.log
1 12 * * * /scripts/simulate_agent.sh logout 1 &> /var/log/agent_error.log
58 2 * * * /scripts/simulate_agent.sh break 1 &> /var/log/agent_error.log
30 3 * * * /scripts/simulate_agent.sh done 1 &> /var/log/agent_error.log
29 6 * * * /scripts/simulate_agent.sh lunch 1 &> /var/log/agent_error.log
31 7 * * * /scripts/simulate_agent.sh done 1 &> /var/log/agent_error.log
32 10 * * * /scripts/simulate_agent.sh web 1 &> /var/log/agent_error.log
58 10 * * * /scripts/simulate_agent.sh done 1 &> /var/log/agent_error.log

# group2
1 2 * * * /scripts/simulate_agent.sh login 2 &> /var/log/agent_error.log
4 14 * * * /scripts/simulate_agent.sh logout 2 &> /var/log/agent_error.log
3 5 * * * /scripts/simulate_agent.sh break 2 &> /var/log/agent_error.log
34 5 * * * /scripts/simulate_agent.sh done 2 &> /var/log/agent_error.log
27 8 * * * /scripts/simulate_agent.sh lunch 2 &> /var/log/agent_error.log
33 9 * * * /scripts/simulate_agent.sh done 2 &> /var/log/agent_error.log
29 12 * * * /scripts/simulate_agent.sh web 2 &> /var/log/agent_error.log
02 13 * * * /scripts/simulate_agent.sh done 2 &> /var/log/agent_error.log

# group3
58 11 * * * /scripts/simulate_agent.sh login 3 &> /var/log/agent_error.log
1 0 * * * /scripts/simulate_agent.sh logout 3 &> /var/log/agent_error.log
1 14 * * * /scripts/simulate_agent.sh break 3 &> /var/log/agent_error.log
28 14 * * * /scripts/simulate_agent.sh done 3 &> /var/log/agent_error.log
30 17 * * * /scripts/simulate_agent.sh lunch 3 &> /var/log/agent_error.log
27 18 * * * /scripts/simulate_agent.sh done 3 &> /var/log/agent_error.log
36 21 * * * /scripts/simulate_agent.sh web 3 &> /var/log/agent_error.log
07 22 * * * /scripts/simulate_agent.sh done 3 &> /var/log/agent_error.log

#group 4
10 14 * * * /scripts/simulate_agent.sh login 4 &> /var/log/agent_error.log
55 1 * * * /scripts/simulate_agent.sh logout 4 &> /var/log/agent_error.log
50 15 * * * /scripts/simulate_agent.sh break 4 &> /var/log/agent_error.log
33 16 * * * /scripts/simulate_agent.sh done 4 &> /var/log/agent_error.log
30 19 * * * /scripts/simulate_agent.sh lunch 4 &> /var/log/agent_error.log
33 20 * * * /scripts/simulate_agent.sh done 4 &> /var/log/agent_error.log
20 23 * * * /scripts/simulate_agent.sh web 4 &> /var/log/agent_error.log
43 23 * * * /scripts/simulate_agent.sh done 4 &> /var/log/agent_error.log
