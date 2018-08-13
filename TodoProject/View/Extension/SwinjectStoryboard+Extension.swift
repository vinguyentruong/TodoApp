//
//  SwinjectStoryboard+Extension.swift
//  TodoProject
//
//  Created by David Nguyen Truong on 7/20/18.
//  Copyright © 2018 David Nguyen Truong. All rights reserved.
//

import Foundation
import Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    @objc class func setup() {
        Container.loggingFunction = nil
        regiserSync()
        registerService()
        registerStoryboard()
    }
    
    private static func regiserSync() {
        let container = SwinjectStoryboard.defaultContainer
        container.register(TaskRepository.self) {_ in
            TaskRepository()
        }.inObjectScope(.container)
        
        container.register(JobManager.self) { _ in
            JobManager()
        }.inObjectScope(.container)
        
        container.register(SyncManager.self, factory: {container in
            let syncManager = SyncManager(taskRepository: container.resolve(TaskRepository.self)!,
                                          appService    : container.resolve(TodoAppService.self)!,
                                          jobManager    : container.resolve(JobManager.self)!)
            return syncManager
        }).inObjectScope(.container)
    }
    
    private static func registerService() {
        let container = SwinjectStoryboard.defaultContainer
        container.register(OAuthProtocol.self) {_ in
                OAuthServiceImpl()
            }.inObjectScope(.container)
        
        container.register(ApiHelper.self) { _ in
                ApiHelper(baseUrl       : Configuration.BaseUrl,
                          oauthProtocol : container.resolve(OAuthProtocol.self))
            }.inObjectScope(.container)
        
        container.register(UploadService.self) { container in
                UploadServiceImplement(apiHelper: container.resolve(ApiHelper.self)!)
            }.inObjectScope(.container)
        
        container.register(TodoAppService.self) { container in
                TodoAppServiceImplement(apiHelper: container.resolve(ApiHelper.self)!)
            }.inObjectScope(.container)
    }
    
    private static func registerStoryboard() {
        let container = SwinjectStoryboard.defaultContainer
        
        container.storyboardInitCompleted(LoginViewController.self) { (container, controller) in
            let viewModel = LoginViewModel(navigator   : Navigator(viewController: controller),
                                           oauthService: container.resolve(OAuthProtocol.self)!,
                                           appService  : container.resolve(TodoAppService.self)!
            )
            controller.viewModel = viewModel
        }
        
        container.storyboardInitCompleted(RegisterViewController.self) { (container, controller) in
            let viewModel = RegisterViewModel(navigator       : Navigator(viewController: controller),
                                              oauthService    : container.resolve(OAuthProtocol.self)!,
                                              uploadService   : container.resolve(UploadService.self)!
            )
            controller.viewModel = viewModel
        }
        
        container.storyboardInitCompleted(ProfileViewController.self) { (container, controller) in
            let viewModel = ProfileViewModel(navigator       : Navigator(viewController: controller),
                                             oauthService    : container.resolve(OAuthProtocol.self)!,
                                             appService      : container.resolve(TodoAppService.self)!,
                                             uploadService   : container.resolve(UploadService.self)!)
            controller.viewModel = viewModel
        }
        
        container.storyboardInitCompleted(MainViewController.self) { (container, controller) in
            let viewModel = MainViewModel(navigator       : Navigator(viewController: controller),
                                          appService      : container.resolve(TodoAppService.self)!,
                                          taskRepository  : container.resolve(TaskRepository.self)!)
            controller.viewModel = viewModel
        }
        
        container.storyboardInitCompleted(TaskDetailViewController.self) { (container, controller) in
            let viewModel = TaskDetailViewModel(navigator       : Navigator(viewController: controller),
                                                appService      : container.resolve(TodoAppService.self)!,
                                                taskRepository  : container.resolve(TaskRepository.self)!)
            controller.viewModel = viewModel
        }
        
        container.storyboardInitCompleted(CreateTaskViewController.self) { (container, controller) in
            let viewModel = CreateTaskViewModel(navigator       : Navigator(viewController: controller),
                                                appService      : container.resolve(TodoAppService.self)!,
                                                taskRepository  : container.resolve(TaskRepository.self)!)
            controller.viewModel = viewModel
        }
    }
}
