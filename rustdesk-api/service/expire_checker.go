package service

import (
	"time"
	"github.com/lejianwen/rustdesk-api/v2/global"
)

type ExpireCheckerService struct {
	stopChan            chan bool
	lastExpiringLogTime time.Time
}

var ExpireChecker *ExpireCheckerService

// NewExpireChecker 创建过期检查服务
func NewExpireChecker() *ExpireCheckerService {
	return &ExpireCheckerService{
		stopChan:            make(chan bool),
		lastExpiringLogTime: time.Now(),
	}
}

// Start 启动过期检查协程
func (ecs *ExpireCheckerService) Start() {
	go ecs.run()
	global.Logger.Info("User expire checker started")
}

// Stop 停止过期检查协程
func (ecs *ExpireCheckerService) Stop() {
	close(ecs.stopChan)
	global.Logger.Info("User expire checker stopped")
}

// run 运行过期检查协程
func (ecs *ExpireCheckerService) run() {
	ticker := time.NewTicker(10 * time.Second) // 每10秒检查一次
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			ecs.checkExpiredUsers()
		case <-ecs.stopChan:
			return
		}
	}
}

// checkExpiredUsers 检查并禁用过期用户
func (ecs *ExpireCheckerService) checkExpiredUsers() {
	disabledCount, err := AllService.UserService.DisableExpiredUsers()
	if err != nil {
		global.Logger.Errorf("Failed to disable expired users: %v", err)
		return
	}
	if disabledCount > 0 {
		global.Logger.Infof("Disabled %d expired users.", disabledCount)
	}

	// 获取即将过期的用户数量（7天内）
	expiringUsers := AllService.UserService.GetExpiringUsers(7)
	if len(expiringUsers) > 0 {
		// Log once per hour
		if time.Since(ecs.lastExpiringLogTime) > time.Hour {
			global.Logger.Infof("Found %d users expiring within 7 days", len(expiringUsers))
			ecs.lastExpiringLogTime = time.Now()
			// 这里可以添加通知逻辑，比如发送邮件或推送通知
		}
	}
}

// GetExpireStats 获取过期统计信息
func (ecs *ExpireCheckerService) GetExpireStats() map[string]interface{} {
	expiredUsers := AllService.UserService.GetExpiredUsers()
	expiringUsers := AllService.UserService.GetExpiringUsers(7)
	
	return map[string]interface{}{
		"expired_count":   len(expiredUsers),
		"expiring_count":  len(expiringUsers),
		"last_check_time": time.Now().Unix(),
	}
} 