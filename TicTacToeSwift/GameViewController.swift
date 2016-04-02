//
//  GameViewController.swift
//  TicTacToeSwift
//
//  Created by id on 3/31/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit

enum ViewCorner: Int {
    case ViewCornerTopLeft
    case ViewCornerTopRight
    case ViewCornerBottomLeft
    case ViewCornerBottomRight
}

class GameViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!

    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var turnLabelStartPoint: CGPoint!

    var viewPositions: Dictionary<Int, CGPoint>!

    var gameEngine: TicTacToeBoard!

    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!

    // #MARK: - view life cycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (gameEngine.currentGameState == GameState.Empty) {
            self.updateTurnLabel()
            self.layoutBoard()
        }

        animator = UIDynamicAnimator.init(referenceView: view)
        snapBehavior.snapPoint = turnLabel.center
        snapBehavior.damping = 0.5
        animator.addBehavior(snapBehavior)

        viewPositions = getViewPositions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = UIColor.blackColor()
        turnLabel.font = UIFont.systemFontOfSize(40)

        snapBehavior = UISnapBehavior.init(item: turnLabel, snapToPoint: turnLabel.center)

        // set up play again button
        playAgainButton.layer.cornerRadius = 10
        playAgainButton.layer.borderWidth = 2
        playAgainButton.layer.borderColor = UIColor.blueColor().CGColor
        playAgainButton.titleLabel?.textColor = UIColor.blueColor()
        playAgainButton.titleLabel?.font = UIFont.systemFontOfSize(30)

        // set up pan gesture
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(moveObject))

        turnLabel.addGestureRecognizer(panGesture)
        panGesture.delegate = self

        turnLabel.userInteractionEnabled = true
        gameEngine = TicTacToeBoard.init()
        gameEngine.addObserver(self, forKeyPath: "playerTurn", options:[], context: nil)
        gameEngine.addObserver(self, forKeyPath: "boardState", options:[.New, .Old], context: nil)
        gameEngine.addObserver(self, forKeyPath: "currentGameState", options:[.New], context: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // #MARK: - segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // #MARK: - kvo
    override func observeValueForKeyPath(keyPath: String?,
                                         ofObject object: AnyObject?,
                                                  change: [String : AnyObject]?,
                                                  context: UnsafeMutablePointer<Void>) {

        if keyPath == "playerTurn" {
            updateTurnLabel()
        } else if keyPath == "boardState" {
            if (gameEngine.currentGameState != GameState.Won &&
                gameEngine.currentGameState != GameState.Tied) {
                updateBoardForChanges(change)
            }
        } else if keyPath == "currentGameState" {
            checkGameStatus()
        }
    }

    func checkGameStatus() {
        switch (gameEngine.currentGameState) {
        case GameState.Empty:
            break;

        case GameState.Started:
            break;

        case GameState.Won:
            showAlertGameOver()
            break;

        case GameState.Tied:
            showAlertGameOver()
            break;

        default:
            break;
        }
    }

    // #MARK: - IBActions
    @IBAction func onButtonTapped(sender: UIButton) {
        let rowCol = getBoardIndexesFromButton(sender)
        let row:UInt = rowCol.first!
        let column:UInt = rowCol.last!
        gameEngine.updateBoardForCurrentPlayerAtRow(row, atColumn: column)
    }

    @IBAction func playAgain(sender: UIButton) {
        playAgainButton.hidden = true
        layoutBoard()
        animator.removeAllBehaviors()
        animator.addBehavior(snapBehavior)
        let keys = viewPositions.keys

        print("after")
        for key in keys{
            // get tag
            let tag:Int = key
            // get CGPoint
            let point = viewPositions[key]!;
            // get view
            let view = self.view.viewWithTag(tag)!
            print(point)
            let snap = UISnapBehavior.init(item: view, snapToPoint: point)
            snap.damping = 0.9
            animator.addBehavior(snap)
            animator.updateItemUsingCurrentState(view)
        }
        gameEngine.restartGame()
        // stop
    }

    // #MARK: - private methods
    func buttonThatIntersectsWithView(view: UIView) -> Int {
        var buttonTag = -1
        for button in buttons {
            let intersect = CGRectIntersectsRect(turnLabel.frame, button.frame)
            if intersect {
                buttonTag = button.tag
                break
            }
        }
        return buttonTag
    }

    func updateTurnLabel() {
        turnLabel.text = gameEngine.playerTurn
        turnLabel.textColor = gameEngine.playerTurn == "O" ? UIColor.greenColor() : UIColor.purpleColor()
    }

    func getBoardIndexesFromButton(button: UIButton) -> Array<UInt> {
        let tag = UInt(button.tag)
        let index = tag / 10
        let row = ((index - 1) / 3) + 1
        let column = ((tag - 1) % UInt(gameEngine.boardSize)) + 1
        return [row, column]
    }

    func pointForCorner(corner:ViewCorner, view:UIView) -> CGPoint {
        var x:CGFloat = 0
        var y:CGFloat = 0
        let rect = view.frame

        switch corner {
        case .ViewCornerTopLeft:
            x = rect.origin.x
            y = rect.origin.y

        case .ViewCornerTopRight:
            x = rect.origin.x + rect.size.width;
            y = rect.origin.y;

        case .ViewCornerBottomLeft:
            x = rect.origin.x;
            y = rect.origin.y + rect.size.height;

        case .ViewCornerBottomRight:
            x = rect.origin.x + rect.size.width;
            y = rect.origin.y + rect.size.height;
        }

        return CGPointMake(x, y)
    }

    func getViewPositions() -> Dictionary<Int, CGPoint> {
        var _viewPositions =  [Int: CGPoint]()

        for view in self.view.subviews {
            let tag = view.tag
            if tag == 0 {
                continue
            }
            _viewPositions[tag] = view.center
            print(view.center)
        }
        return _viewPositions
    }

    func showAlertGameOver() {
        var title: String = ""
        if gameEngine.currentGameState == GameState.Won {
            title = "Player \(gameEngine.playerTurn) Won!"
        } else if gameEngine.currentGameState == GameState.Tied {
            title = "Game Tied"
        }

        let alert = UIAlertController.init(title: title,
                                           message: "",
                                           preferredStyle: UIAlertControllerStyle.ActionSheet)

        let action = UIAlertAction.init(title: "Play Again",
                                        style: UIAlertActionStyle.Default) { (UIAlertAction) in
            self.animator.removeAllBehaviors()
            // way without NSArray?
            let dynamicItems:NSArray = [self.helpButton, self.turnLabel, self.playAgainButton].arrayByAddingObjectsFromArray(self.buttons)
            self.playAgainButton.hidden = false

            let dynamics = UIDynamicItemBehavior.init(items: dynamicItems as! Array)
            dynamics.elasticity = 1.0
            dynamics.allowsRotation = true

            let gravity = UIGravityBehavior.init(items: dynamicItems as! Array)
            let collision = UICollisionBehavior.init(items: dynamicItems as! Array)

            let topLeft = self.pointForCorner(ViewCorner.ViewCornerTopLeft, view: self.view)
            let topRight = self.pointForCorner(ViewCorner.ViewCornerTopRight, view: self.view)
            let bottomLeft = self.pointForCorner(ViewCorner.ViewCornerBottomLeft, view: self.view)
            let bottomRight = self.pointForCorner(ViewCorner.ViewCornerBottomRight, view: self.view)

            collision.addBoundaryWithIdentifier("left", fromPoint: topLeft, toPoint: bottomLeft)
            collision.addBoundaryWithIdentifier("bottom", fromPoint: bottomLeft, toPoint: bottomRight)
            collision.addBoundaryWithIdentifier("right", fromPoint: topRight, toPoint: bottomRight)
            collision.addBoundaryWithIdentifier("top", fromPoint: topLeft, toPoint: topRight)

            self.animator.addBehavior(gravity)
            self.animator.addBehavior(collision)
            self.animator.addBehavior(dynamics)
            self.animator.addBehavior(self.snapBehavior)

            for dynamicItem in dynamicItems {
                self.animator.updateItemUsingCurrentState(dynamicItem as! UIDynamicItem)
            }
        }
        alert.addAction(action)
        presentViewController(alert, animated: true) { }
    }

    func layoutBoard() {
        turnLabel.text = gameEngine.playerTurn!
        for button in buttons {
            button.layer.cornerRadius = 10.0
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.blueColor().CGColor
            button.titleLabel!.font = UIFont.systemFontOfSize(40)
            button.setTitle(" ", forState: UIControlState.Normal)
        }
    }

    func updateBoardForChanges(change: [String: AnyObject]?) {
        let new = change!["new"] as! String
        let old = change!["old"] as! String

        var diffs: Array<Int> = []
        var counter = 0
        for character in old.characters {
            let isSame = (character == new[new.startIndex.advancedBy(counter)])
            if !isSame {
                diffs.append(counter)
            }
            counter = counter + 1
        }

        for diff in diffs {
            let tag = (diff + 1) * 10
            let button:UIButton = view.viewWithTag(tag) as! UIButton
            let range = NSMakeRange(diff, 1)
            button.setTitle(gameEngine.boardState.substringWithRange(range), forState: UIControlState.Normal)
            let buttonColor = gameEngine.playerTurn=="O" ? UIColor.greenColor(): UIColor.purpleColor()
            button.setTitleColor(buttonColor, forState: UIControlState.Normal)
            button.layer.borderColor = buttonColor.CGColor
        }
    }

    func moveObject(panGesture: UIPanGestureRecognizer) {
        if (panGesture.state == UIGestureRecognizerState.Ended){
            let tagIntersect = buttonThatIntersectsWithView(turnLabel)
            let doesIntersect = tagIntersect != -1
            var button:UIButton = UIButton()

            if (doesIntersect) {
                button = view.viewWithTag(tagIntersect) as! UIButton
                let rowCol = getBoardIndexesFromButton(button)
                let row = rowCol.first! as UInt
                let col = rowCol.last! as UInt
                let canMoveToSquare = gameEngine.canUpdateBoardAtRow(row, atColumn: col)
                if (canMoveToSquare && doesIntersect) {
                    gameEngine.updateBoardForCurrentPlayerAtRow(row, atColumn: col)
                }
            }
            animator.updateItemUsingCurrentState(turnLabel)
        } else {
            turnLabel.center = panGesture.locationInView(turnLabel!.superview)
        }
    }
}
