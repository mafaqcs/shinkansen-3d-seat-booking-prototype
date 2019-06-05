//
//  ViewControllerAnimatedTransitioning.swift
//  Shinkansen Tickets Booking Prototype
//
//  Created by Virakri Jinangkul on 6/2/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit
import Kumi


class ViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting : Bool
    
    lazy var animationStyle: UIViewAnimationStyle = {
        UIViewAnimationStyle.transitionAnimationStyle
    }()
    
    lazy var CAAnimationStyle: CABasicAnimationStyle = {
        CABasicAnimationStyle.transitionAnimationStyle
    }()
    
    init(isPresenting : Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationStyle.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        isPresenting ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        
        let parentVC = isPresenting ? fromViewController : toViewController
        
        let childVC = isPresenting ? toViewController : fromViewController
        
        // MARK: Set all the views in place and have been processed thru Autolayout
        parentVC?.view.layoutIfNeeded()
        childVC?.view.layoutIfNeeded()
        
        // MARK: Transition Between BookingViewController
        if let fromBookingVC = fromViewController as? BookingViewController,
            let toBookingVC = toViewController as? BookingViewController {
            
            struct AnimateObject {
                let fromVC: BookingViewController
                let toVC: BookingViewController
                
                func _animate(fromView: UIView, fromParentView: UIView,
                             toView: UIView, toParentView: UIView,
                             basedHorizontalAnimationOffset: CGFloat = 0,
                             basedVerticalAnimationOffset: CGFloat = 0,
                             percentageEndPoint: TimeInterval = 1) {
                    
                    // Sets all animated views to orginal position before them get calculated
                    fromView.transform = .identity
                    toView.transform = .identity
                    
                    var displacement: CGPoint = .zero
                    
                    var isTransitioningHiddenView = false
                    
                    if fromView.isHidden || toView.isHidden {
                        
                        isTransitioningHiddenView = true
                        
                        // MARK: Hidden views will be slide up
                        if fromView.isHidden  {
                            displacement.x = CGFloat(-basedHorizontalAnimationOffset).systemSizeMuliplier()
                            displacement.y = CGFloat(-basedVerticalAnimationOffset).systemSizeMuliplier()
                        }
                        
                        if toView.isHidden  {
                            displacement.x = CGFloat(basedHorizontalAnimationOffset).systemSizeMuliplier()
                            displacement.y = CGFloat(basedVerticalAnimationOffset).systemSizeMuliplier()
                        }
                        
                    } else {
                        let fromActualFrame = fromView.frame(in: fromParentView)
                        let toActualFrame = toView.frame(in: toParentView)
                        
                        displacement = CGPoint(x: toActualFrame.midX - fromActualFrame.midX,
                                               y: toActualFrame.minY - fromActualFrame.minY)
                    }
                    
                    toView.transform.tx = -displacement.x
                    toView.transform.ty = -displacement.y
                    
                    // MARK: In case one view is hidden
                    if fromView.isHidden  {
                        toView.alpha = 0
                    }
                    
                    if toView.isHidden  {
                        fromView.alpha = 1
                    }
                    
                    // mutate
                    let animationStyle = UIViewAnimationStyle.transitionAnimationStyle
                    var mutatedAnimationStyle = animationStyle
                    mutatedAnimationStyle.duration = animationStyle.duration * (fromView.isHidden ? 1 - percentageEndPoint : percentageEndPoint)
                    mutatedAnimationStyle.delay = animationStyle.duration - mutatedAnimationStyle.duration
                    
                    UIView.animate(withStyle: isTransitioningHiddenView ? mutatedAnimationStyle : animationStyle,
                                   delay: fromView.isHidden ? mutatedAnimationStyle.delay : 0,
                                   animations: {
                                    fromView.transform.tx = displacement.x
                                    fromView.transform.ty = displacement.y
                                    toView.transform = .identity
                                    
                                    // MARK: Animation for one that is hidden
                                    if fromView.isHidden {
                                        toView.alpha = 1
                                    }
                                    
                                    if toView.isHidden {
                                        fromView.alpha = 0
                                    }
                    })
                }
                
                func animate(view: ((BookingViewController) -> UIView),
                             parentView: ((BookingViewController) -> UIView)? = nil,
                             basedVerticalAnimationOffset: CGFloat,
                             percentageEndPoint: TimeInterval = 0.4
                    ) {
                    
                    _animate(fromView: view(fromVC),
                             fromParentView: (parentView != nil) ? parentView!(fromVC) : (view(fromVC).superview ?? UIView()),
                             toView: view(toVC),
                             toParentView: (parentView != nil) ? parentView!(toVC) : (view(toVC).superview ?? UIView()),
                             basedVerticalAnimationOffset: 18,
                             percentageEndPoint: 0.4)
                }
            }
            
            let animateObject = AnimateObject(fromVC: fromBookingVC, toVC: toBookingVC)
            
            animateObject.animate(view: {$0.dateLabelSetView},
                                  parentView: {$0.view},
                                  basedVerticalAnimationOffset: 18)
            
            animateObject.animate(view: {$0.headerRouteInformationView},
                                  parentView: {$0.view},
                                  basedVerticalAnimationOffset: 72)
            
            animateObject.animate(view: {$0.headerRouteInformationView
                .stationPairView
                .fromStationHeadlineView
                .subtitleLabel},
                                  basedVerticalAnimationOffset: 6)
            
            animateObject.animate(view: {$0.headerRouteInformationView
                .stationPairView
                .toStationHeadlineView
                .subtitleLabel},
                                  basedVerticalAnimationOffset: 6)
            
            animateObject.animate(view: {$0.headerRouteInformationView
                .descriptionSetView},
                                  basedVerticalAnimationOffset: 18)
            
            animateObject.animate(view: {$0.headerRouteInformationView
                .descriptionSetView.carNumberSetView},
                                  basedVerticalAnimationOffset: 12)
            
            animateObject.animate(view: {$0.headerRouteInformationView
                .descriptionSetView
                .seatNumberSetView},
                                  basedVerticalAnimationOffset: 12)
            
            animateObject.animate(view: {$0.headerRouteInformationView
                .descriptionSetView
                .priceSetView},
                                  basedVerticalAnimationOffset: 12)
            
        }
        
       
        
        let percentageEndPoint: TimeInterval = 0.4
        
        
        // MARK: Transition in and out views in BookingCriteriaViewController
        if let bookingCriterialVC = fromViewController as? BookingCriteriaViewController {
            let transitionDirection: UIView.TransitionalDirection = .transitionOut
            bookingCriterialVC.headerStackView.translateAndFade(as: transitionDirection,
                                                              animationStyle: animationStyle,
                                                              percentageEndPoint: percentageEndPoint,
                                                              translate: .init(x: 0, y: -72))
            bookingCriterialVC.horizontalStationStackView.translateAndFade(as: transitionDirection,
                                                                         animationStyle: animationStyle,
                                                                         percentageEndPoint: percentageEndPoint,
                                                                         translate: .init(x: 0, y: -48))
            bookingCriterialVC.dateSegmentedContainerView.translateAndFade(as: transitionDirection,
                                                                         animationStyle: animationStyle,
                                                                         percentageEndPoint: percentageEndPoint,
                                                                         translate: .init(x: 0, y: -32))
            bookingCriterialVC.timeSegmentedContainerView.translateAndFade(as: transitionDirection,
                                                                         animationStyle: animationStyle,
                                                                         percentageEndPoint: percentageEndPoint,
                                                                         translate: .init(x: 0, y: -16))
            bookingCriterialVC.mainCallToActionButton.translateAndFade(as: transitionDirection,
                                                                     animationStyle: animationStyle,
                                                                     percentageEndPoint: percentageEndPoint,
                                                                     translate: .init(x: 0, y: -16))
        } else if let bookingCriterialVC = toViewController as? BookingCriteriaViewController {
            let transitionDirection: UIView.TransitionalDirection = .transitionIn
            bookingCriterialVC.headerStackView.translateAndFade(as: transitionDirection,
                                                              animationStyle: animationStyle,
                                                              percentageEndPoint: percentageEndPoint,
                                                              translate: .init(x: 0, y: -72))
            bookingCriterialVC.horizontalStationStackView.translateAndFade(as: transitionDirection,
                                                                         animationStyle: animationStyle,
                                                                         percentageEndPoint: percentageEndPoint,
                                                                         translate: .init(x: 0, y: -48))
            bookingCriterialVC.dateSegmentedContainerView.translateAndFade(as: transitionDirection,
                                                                         animationStyle: animationStyle,
                                                                         percentageEndPoint: percentageEndPoint,
                                                                         translate: .init(x: 0, y: -32))
            bookingCriterialVC.timeSegmentedContainerView.translateAndFade(as: transitionDirection,
                                                                         animationStyle: animationStyle,
                                                                         percentageEndPoint: percentageEndPoint,
                                                                         translate: .init(x: 0, y: -16))
            bookingCriterialVC.mainCallToActionButton.translateAndFade(as: transitionDirection,
                                                                     animationStyle: animationStyle,
                                                                     percentageEndPoint: percentageEndPoint,
                                                                     translate: .init(x: 0, y: -16))
        }
        
        // MARK: Transition in and out views in SeatMapSelectionViewController
        if let seatMapSelectionVC = toViewController as? SeatMapSelectionViewController {
            seatMapSelectionVC.mainCallToActionButton.translateAndFade(as: .transitionIn,
                                                                     animationStyle: animationStyle,
                                                                     percentageEndPoint: percentageEndPoint,
                                                                     translate: .init(x: 0, y: seatMapSelectionVC.mainCallToActionButton.bounds.height * 0.5))
        } else if let seatMapSelectionVC = fromViewController as? SeatMapSelectionViewController {
            seatMapSelectionVC.mainCallToActionButton.translateAndFade(as: .transitionOut,
                                                                     animationStyle: animationStyle,
                                                                     percentageEndPoint: percentageEndPoint,
                                                                     translate: .init(x: 0, y: seatMapSelectionVC.mainCallToActionButton.bounds.height * 0.5))
        }
        
        // MARK: Transition in and out views in BookingConfirmationViewController
        if let bookingConfirmationVC = toViewController as? BookingConfirmationViewController {
            bookingConfirmationVC.mainCallToActionButton.translateAndFade(as: .transitionIn,
                                                                     animationStyle: animationStyle,
                                                                     percentageEndPoint: percentageEndPoint,
                                                                     translate: .init(x: 0, y: -bookingConfirmationVC.mainCallToActionButton.bounds.height * 0.25))
        } else if let bookingConfirmationVC = fromViewController as? BookingConfirmationViewController {
            bookingConfirmationVC.mainCallToActionButton.translateAndFade(as: .transitionOut,
                                                                     animationStyle: animationStyle,
                                                                     percentageEndPoint: percentageEndPoint,
                                                                     translate: .init(x: 0, y: -bookingConfirmationVC.mainCallToActionButton.bounds.height * 0.25))
        }
        
        // MARK: Transition out views in TrainSelectionViewController
        if let trainSelectionVC = fromViewController as? TrainSelectionViewController,
            toViewController is BookingCriteriaViewController {
            
            trainSelectionVC.mainTableView.translateAndFade(as: .transitionOut,
                                                          animationStyle: animationStyle,
                                                          percentageEndPoint: percentageEndPoint,
                                                          translate: .init(x: 0, y: 72))
            
            trainSelectionVC.mainTableView.visibleCells.enumerated().forEach {
                (index, cell) in
                cell.translateAndFade(as: .transitionOut,
                                    animationStyle: animationStyle,
                                    percentageEndPoint: percentageEndPoint,
                                    translate: .init(x: 0, y: CGFloat(index) * 16))
            }
        }
        
        // MARK: Transition views in SeatMapSelectionViewController to BookingConfirmationViewController
        if let seatMapSelectionVC = fromViewController as? SeatMapSelectionViewController,
            let bookingConfirmationVC = toViewController as? BookingConfirmationViewController {
            seatMapSelectionVC.mainCardView.translateAndFade(as: .transitionOut,
                                                           animationStyle: animationStyle,
                                                           percentageEndPoint: 1,
                                                           translate: .init(x: 0, y: seatMapSelectionVC.mainCardView.bounds.height))
            
            bookingConfirmationVC.mainCardView.translateAndFade(as: .transitionIn,
                                                           animationStyle: animationStyle,
                                                           percentageEndPoint: 0,
                                                           translate: .init(x: 0, y: -bookingConfirmationVC.mainCardView.bounds.height))
            bookingConfirmationVC.dateLabel.translateAndFade(as: .transitionIn,
                                                              animationStyle: animationStyle,
                                                              percentageEndPoint: 0,
                                                              translate: .init(x: 0, y: -bookingConfirmationVC.mainCardView.bounds.height + bookingConfirmationVC.dateLabel.bounds.height))
        } else if let seatMapSelectionVC = toViewController as? SeatMapSelectionViewController,
            let bookingConfirmationVC = fromViewController as? BookingConfirmationViewController {
            seatMapSelectionVC.mainCardView.translateAndFade(as: .transitionIn,
                                                           animationStyle: animationStyle,
                                                           percentageEndPoint: 0,
                                                           translate: .init(x: 0, y: seatMapSelectionVC.mainCardView.bounds.height))
            
            bookingConfirmationVC.mainCardView.translateAndFade(as: .transitionOut,
                                                              animationStyle: animationStyle,
                                                              percentageEndPoint: 1,
                                                              translate: .init(x: 0, y: -bookingConfirmationVC.mainCardView.bounds.height))
            
            bookingConfirmationVC.dateLabel.translateAndFade(as: .transitionOut,
                                                           animationStyle: animationStyle,
                                                           percentageEndPoint: 1,
                                                           translate: .init(x: 0, y: -bookingConfirmationVC.mainCardView.bounds.height + bookingConfirmationVC.dateLabel.bounds.height))
        }
        
        
        // MARK: Transition views in TrainSelectionViewController to SeatClassSelectionViewController
        if let trainSelectionVC = fromViewController as? TrainSelectionViewController,
            let seatClassSelectionVC = toViewController as? SeatClassSelectionViewController {
            
            // Demo
            if let selectedIndexPath = trainSelectionVC.selectedIndexPath {
                guard let cell = trainSelectionVC.mainTableView.cellForRow(at: selectedIndexPath) as? TrainScheduleTableViewCell else { return }
                
                // MARK: Fade all other cells
                trainSelectionVC.mainTableView.visibleCells.forEach { (otherCell) in
                    if otherCell != cell {
                        otherCell.fadeAnimation(as: .transitionOut,
                                                animationStyle: animationStyle,
                                                percentageEndPoint: 0.3)
                        otherCell.transformAnimation(as: .transitionOut,
                                                     animationStyle: animationStyle,
                                                     percentageEndPoint: 0.3,
                                                     transform: CGAffineTransform(scaleX: 0.96, y: 0.96))
                    }
                }
                
                // MARK: Fade all other cells
                seatClassSelectionVC.mainTableView.visibleCells.forEach { (otherCell) in
                    otherCell.fadeAnimation(as: .transitionIn,
                                            animationStyle: animationStyle,
                                            percentageEndPoint: 0.55)
                    
                }
                
                //
                let originRectInOriginView = cell.cardView.frame(in: cell.contentView)
                
                seatClassSelectionVC.mainTableView.visibleCells.forEach { (destinationCell) in
                    guard let destinationCell = destinationCell as? SeatClassTableViewCell else { return }
                     let destinationRectInOriginView = destinationCell.cardView.frame(in: cell.contentView)
                    
                    let dummyView = UIView()
                    cell.contentView.addSubview(dummyView)
                    
                    dummyView.layer.setLayer(cell.cardView.layer.layerStyle)
                    dummyView.layer.withNoShadow()
                    cell.contentView.layer.setShadow(cell.cardView.layer.shadowStyle)
                    
                    cell.cardView.layer.removeAllAnimations()
                    cell.cardView.contentView.layer.removeAllAnimations()
                    
                    cell.contentView.sendSubviewToBack(dummyView)
                    if destinationCell == seatClassSelectionVC.mainTableView.visibleCells.last {
                        cell.cardView.layer.setLayer(LayerStyle())
                        cell.cardView.contentView.backgroundColor = .clear
                        cell.cardView.contentView.fadeAnimation(as: .transitionOut, animationStyle: animationStyle, percentageEndPoint: 0.3)
                    }
                    
                    dummyView.frame = originRectInOriginView
                    
                    var muatatedAnimationStyle = animationStyle
                    muatatedAnimationStyle.duration = animationStyle.duration * 0.35
                    UIView.animate(withStyle: muatatedAnimationStyle,
                                   delay: 0.65 * animationStyle.duration,
                                   animations: {
                        dummyView.alpha = 0
                    })
                    
                    
                    
                    UIView.animate(withStyle: animationStyle, animations: {
                        dummyView.frame = destinationRectInOriginView
                    }, completion: {
                        _ in
                        dummyView.removeFromSuperview()
                    })
                    
                    let originRectInDestinationView = cell.cardView.frame(in: destinationCell.contentView)
                    let destinationRectInDestinationView = destinationCell.cardView.frame(in: destinationCell.contentView)
                    destinationCell.cardView.frame = originRectInDestinationView
                    
                    UIView.animate(withStyle: animationStyle, animations: {
                        destinationCell.cardView.frame = destinationRectInDestinationView
                    })
                }
            }
        }
        
        // MARK: Transition views in SeatClassSelectionViewController to TrainSelectionViewController (Backward)
        if let trainSelectionVC = toViewController as? TrainSelectionViewController,
            let seatClassSelectionVC = fromViewController as? SeatClassSelectionViewController {
            
            // Demo
            if let selectedIndexPath = trainSelectionVC.selectedIndexPath {
                guard let cell = trainSelectionVC.mainTableView.cellForRow(at: selectedIndexPath) as? TrainScheduleTableViewCell else { return }
                
                // MARK: Fade all other cells
                trainSelectionVC.mainTableView.visibleCells.forEach { (otherCell) in
                    if otherCell != cell {
                        otherCell.fadeAnimation(as: .transitionOut,
                                                animationStyle: animationStyle,
                                                percentageEndPoint: 0.3)
                        otherCell.transformAnimation(as: .transitionOut,
                                                     animationStyle: animationStyle,
                                                     percentageEndPoint: 0.3,
                                                     transform: CGAffineTransform(scaleX: 0.96, y: 0.96))
                    }
                }
                
                // MARK: Fade all other cells
                seatClassSelectionVC.mainTableView.visibleCells.forEach { (otherCell) in
                    otherCell.fadeAnimation(as: .transitionIn,
                                            animationStyle: animationStyle,
                                            percentageEndPoint: 0.55)
                    
                }
                
                //
                let originRectInOriginView = cell.cardView.frame(in: cell.contentView)
                
                seatClassSelectionVC.mainTableView.visibleCells.forEach { (destinationCell) in
                    guard let destinationCell = destinationCell as? SeatClassTableViewCell else { return }
                    let destinationRectInOriginView = destinationCell.cardView.frame(in: cell.contentView)
                    
                    let dummyView = UIView()
                    cell.contentView.addSubview(dummyView)
                    
                    dummyView.layer.setLayer(cell.cardView.layer.layerStyle)
                    dummyView.layer.withNoShadow()
                    cell.contentView.layer.setShadow(cell.cardView.layer.shadowStyle)
                    
                    cell.cardView.layer.removeAllAnimations()
                    cell.cardView.contentView.layer.removeAllAnimations()
                    
                    cell.contentView.sendSubviewToBack(dummyView)
                    if destinationCell == seatClassSelectionVC.mainTableView.visibleCells.last {
                        cell.cardView.layer.setLayer(LayerStyle())
                        cell.cardView.contentView.backgroundColor = .clear
                        cell.cardView.contentView.fadeAnimation(as: .transitionOut, animationStyle: animationStyle, percentageEndPoint: 0.3)
                    }
                    
                    dummyView.frame = originRectInOriginView
                    
                    var muatatedAnimationStyle = animationStyle
                    muatatedAnimationStyle.duration = animationStyle.duration * 0.35
                    UIView.animate(withStyle: muatatedAnimationStyle,
                                   delay: 0.65 * animationStyle.duration,
                                   animations: {
                                    dummyView.alpha = 0
                    })
                    
                    
                    
                    UIView.animate(withStyle: animationStyle, animations: {
                        dummyView.frame = destinationRectInOriginView
                    }, completion: {
                        _ in
                        dummyView.removeFromSuperview()
                    })
                    
                    let originRectInDestinationView = cell.cardView.frame(in: destinationCell.contentView)
                    let destinationRectInDestinationView = destinationCell.cardView.frame(in: destinationCell.contentView)
                    destinationCell.cardView.frame = originRectInDestinationView
                    
                    UIView.animate(withStyle: animationStyle, animations: {
                        destinationCell.cardView.frame = destinationRectInDestinationView
                    })
                }
            }
        }
        
        
        // MARK: Transition views in SeatClassSelectionViewController to SeatMapSelectionViewController
        if let seatClassSelectionVC = fromViewController as? SeatClassSelectionViewController,
            let seatMapSelectionVC = toViewController as? SeatMapSelectionViewController {
            
            // Demo
            if let selectedIndexPath = seatClassSelectionVC.selectedIndexPath,
                let cell = seatClassSelectionVC.mainTableView.cellForRow(at: selectedIndexPath) as? SeatClassTableViewCell {
                
                seatClassSelectionVC.mainTableView.visibleCells.forEach { (otherCell) in
                    if otherCell != cell {
                        otherCell.translateAndFade(as: .transitionOut, animationStyle: animationStyle, percentageEndPoint: 0.3, translate: .zero)
                    }
                }
                let originRectInMainContentView = cell.cardView.frame(in: seatMapSelectionVC.mainContentView)
                let destinationRectInMainContentView = seatMapSelectionVC.mainCardView.frame(in: seatMapSelectionVC.mainContentView)
                
//                let originRectInCellContentView = cell.cardView.frame(in: cell.contentView)
                let destinationRectInCellContentView = seatMapSelectionVC.mainCardView.frame(in: cell.contentView)
                
                if let animatingCardView = seatMapSelectionVC.mainCardView {
                    
                    let animatingCardViewInCell = cell.cardView
                    
                    animatingCardView.layer.cornerRadius = animatingCardViewInCell.layer.cornerRadius
                    animatingCardView.contentView.layer.cornerRadius = animatingCardViewInCell.contentView.layer.cornerRadius
                    
                    animatingCardView.alpha = 0
                    
                    animatingCardView.frame = originRectInMainContentView
                    animatingCardView.contentView.frame = animatingCardView.bounds
                    
                    animatingCardViewInCell.contentView.layer.removeAllAnimations()
                    animatingCardViewInCell.layer.removeAllAnimations()
                    
                    var mutatedAnimationStyle = animationStyle
                    mutatedAnimationStyle.duration = animationStyle.duration * 0.6
                    mutatedAnimationStyle.delay = 0
                    
                    UIView.animate(withStyle: mutatedAnimationStyle, animations: {
                        animatingCardView.alpha = 1
                        
                        animatingCardView.frame = destinationRectInMainContentView
                        animatingCardView.contentView.frame = animatingCardView.bounds
                        
                        animatingCardView.layer.cornerRadius = layerStyle.largeCard.normal().cornerRadius
                        animatingCardView.contentView.layer.cornerRadius = layerStyle.largeCard.normal().cornerRadius
                        
                        animatingCardViewInCell.frame = destinationRectInCellContentView
                        
                        let scaleFactor = animatingCardViewInCell.bounds.width / animatingCardViewInCell.contentView.bounds.width
                        animatingCardViewInCell.contentView.transform = .init(scaleX: scaleFactor, y: scaleFactor)
                        
                        animatingCardViewInCell.contentView.transform.tx = animatingCardViewInCell.bounds.midX - animatingCardViewInCell.contentView.bounds.midX
                        
                        animatingCardViewInCell.contentView.transform.ty = originRectInMainContentView.minY
                        
                        animatingCardViewInCell.layer.cornerRadius = layerStyle.largeCard.normal().cornerRadius
                        animatingCardViewInCell.contentView.layer.cornerRadius = 0
                        
                        animatingCardViewInCell.contentView.alpha = 0
                        animatingCardViewInCell.alpha = 0
                    })
                }
            }
        }
        
        
        
        
        container.backgroundColor = toView.backgroundColor
        toView.backgroundColor = toView.backgroundColor?.withAlphaComponent(0)
        
        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(0)
        
        // MARK: Perform Animation
        UIView
            .animate(withStyle: animationStyle,
                     animations: {
                        toView.backgroundColor = toView.backgroundColor?.withAlphaComponent(0.001)
                        
//                        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(1)
            },
                     completion: {
                        finished in
                        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(1)
                        toView.backgroundColor = toView.backgroundColor?.withAlphaComponent(1)
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        
        
    }
}