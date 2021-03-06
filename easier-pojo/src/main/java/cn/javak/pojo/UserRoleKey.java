package cn.javak.pojo;


import java.io.Serializable;

/**
 * user_role
 * @author 
 */
public class UserRoleKey implements Serializable {
    private Integer userId;

    private Integer roleId;

    public UserRoleKey(Integer userId, Integer roleId) {
        this.userId = userId;
        this.roleId = roleId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getRoleId() {
        return roleId;
    }

    public void setRoleId(Integer roleId) {
        this.roleId = roleId;
    }
}