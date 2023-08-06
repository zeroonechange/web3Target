自动化测试 

```rust
编写测试及控制执行
	cargo test
	自定义失败信息
	测试panic  expected    
	分割命令行参数    --test-threads=1   --show-output   部分测试  单个测试   名称过滤  忽略部分测试  组合过滤  

单元测试和集成测试 
	单元测试  某一个代码单元  rust支持对私有函数进行测试 
	集成测试  某一个功能进行测试  

断言
	assert!   assert_eq!   assert_ne!  
	debug_assert!   debug_assert_eq!    debug_assert_ne!

用 github actions 进行持续集成 
	持续集成会定期拉同一个项目的代码，自动化构建  
	github actions - 持续集成平台  参考：
		GitHub 用户统计信息案例  https://github.com/vn7n24fzkq/github-profile-summary-cards
		官方市场 https://github.com/marketplace?type=actions 
		awesome系列  https://github.com/sdras/awesome-actions
		workflow模版  https://github.com/actions/starter-workflows

	基本概念
		github actions： 每个项目都拥有一个actions  可包含多个工作流
		workflow 工作流： 描述了一次持续集成的过程 
		job 作业： 一个工作流可包含多个作业，按照顺序一步一步完成
		step 步骤： 每个作业由多个步骤组成，按照顺序一步一步完成
		action 动作： 每个步骤包含多个动作

	真实案例： 生成github 统计卡片
			 使用actions来构建rust项目  

基准测试 benchmark
	性能测试包含了俩种： 压力测试和基准测试    基准测试针对代码，测试一段代码运行速度，比如排序算法
	社区提供的  criterion.rs    跟上一次运行的结果进行差异对比    展示详细的结果图表 			   

```
