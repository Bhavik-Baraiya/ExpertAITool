//
//  AITutorNavigationController.swift
//  ExpertAITool
//
//  Created by Bhavik Baraiya on 03/06/26.
//


import UIKit
import SwiftUI
import SwiftData

/// The primary interface for controlling the Framework flow.
/// Exposing to Objective-C requires inheriting from NSObject and tagging with @objc.
@objc(AITutorNavigationController)
public final class AITutorNavigationController: NSObject {
    
    private let presentingViewController: UIViewController
    private var hostingController: UIViewController?
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            QuestionBank.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
   
    @objc
    public init(presentingViewController: UIViewController) {
        Logger.shared.log(content: "Initialized AITutorNavigationController")
        self.presentingViewController = presentingViewController
        super.init()
    }
    
    /// Launches the internal SwiftUI flow modally.
    @objc
    public func presentAITutorScreen(with questionInput: String, and screenTitle: String, presented: @escaping (Bool) -> Void) {
        Logger.shared.log(content: "Presenting AITutor Screen")
        let primaryView = AITutorHomeView(
            questionInput: questionInput,
            screenTitle: screenTitle,
            onDismiss: { [weak self] in
                Logger.shared.log(content: "Dismissed AITutor Screen")
                self?.hostingController?.dismiss(animated: true, completion: nil)
            },
            presented: {
                Logger.shared.log(content: "Presented AITutor Screen")
                presented(true)
            }
        )
        .modelContainer(sharedModelContainer)
        
        let hostingVC = UIHostingController(rootView: primaryView)
        hostingVC.modalPresentationStyle = .fullScreen
        self.hostingController = hostingVC
        presentingViewController.present(hostingVC, animated: true, completion: nil)
    }
    
    @objc
    public func checkAvailabilityOfFoundationModel(completion: (Bool, String) -> Void)  {
         AITutorService.shared.checkAvailability { isAvailable, message in
             if isAvailable {
                 Logger.shared.log(content: "FoundationModel is available.")
                 completion(true, message)
             } else {
                 Logger.shared.log(content: "FoundationModel is not available: \(message)")
                 completion(false, message)
             }
         }
    }
    
    private func dismissFlow() {
        hostingController?.dismiss(animated: true, completion: { [weak self] in
            self?.hostingController = nil
        })
    }
}
