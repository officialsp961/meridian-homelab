# Phase 5

# Decisions
1. Create an OU for each department
2. Create child OU for users and computers
3. Create a Meridian OU at top level

# Reasons
1. Organize by department  
    - Doing so enables department absed policies and control
    - Each department can have differeing permissions to shared resources such as network shares
2. Splitting users and computers
    - Keeps the directory tidy and easy to read by having clear separation between user and computer policies, instead of one long list of GPO at the root of the OU
3. Top level Meridian OU
    - A top-level OU gives me a place to link GPOs that apply only to company users and computers, and not to built-in accounts or domain controllers.
    - Prevents domain controllers from getting gpo that are meant for the entire org.