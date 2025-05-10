public class UserPermissionHelper {

    public static Boolean isSystemAdminWithPermission(String permissionSetName) {
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        if (currentUser.Profile.Name != 'System Administrator') return false;

        return [SELECT COUNT() FROM PermissionSetAssignment 
                                WHERE AssigneeId = :currentUser.Id AND PermissionSet.Name = :permissionSetName] > 0;
    }
}