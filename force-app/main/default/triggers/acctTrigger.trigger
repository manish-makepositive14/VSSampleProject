trigger acctTrigger on Account (before update) {
 system.debug('##'+trigger.new);
 system.debug('####'+trigger.old);
 List<userRole> use = [Select id,name from userRole limit 1];
 system.debug('sfsf'+use);
 UserRole role = new UserRole();
 role.DeveloperName = 'BelowCEO';
 role.ParentRoleId = use[0].id;
 insert role;
}