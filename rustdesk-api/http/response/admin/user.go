package admin

import "github.com/lejianwen/rustdesk-api/v2/model"

type LoginPayload struct {
	Username   string   `json:"username"`
	Email      string   `json:"email"`
	Avatar     string   `json:"avatar"`
	Token      string   `json:"token"`
	RouteNames []string `json:"route_names"`
	Nickname   string   `json:"nickname"`
}

func (lp *LoginPayload) FromUser(user *model.User) {
	lp.Username = user.Username
	lp.Email = user.Email
	lp.Avatar = user.Avatar
	lp.Nickname = user.Nickname
}

type UserOauthItem struct {
	Op     string `json:"op"`
	Status int    `json:"status"`
}

// UserExpireInfo 用户过期信息
type UserExpireInfo struct {
	UserId    uint   `json:"user_id"`
	Username  string `json:"username"`
	Email     string `json:"email"`
	ExpireAt  int64  `json:"expire_at"`
	Status    int    `json:"status"`
	IsExpired bool   `json:"is_expired"`
	DaysLeft  int    `json:"days_left"` // 剩余天数，-1表示已过期
}

// ExpireStats 过期统计信息
type ExpireStats struct {
	ExpiredCount   int   `json:"expired_count"`
	ExpiringCount  int   `json:"expiring_count"`
	LastCheckTime  int64 `json:"last_check_time"`
}
