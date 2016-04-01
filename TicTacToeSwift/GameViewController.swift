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
    let playerTurnContext = UnsafeMutablePointer<()>()
    let boardStateContext = UnsafeMutablePointer<()>()
    let currentGameStateContext = UnsafeMutablePointer<()>()

    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!

    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var turnLabelStartPoint: CGPoint!

    var gameEngine: TicTacToeBoard!

    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!

    private static var myContext = 0

    // #MARK: - view life cycle
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

        let panGesture = UIPanGestureRecognizer.init(target: self, action: Selector("panAction:"))

        turnLabel.addGestureRecognizer(panGesture)
        panGesture.delegate = self

        turnLabel.userInteractionEnabled = true
        gameEngine = TicTacToeBoard.init()
        gameEngine.addObserver(self, forKeyPath: "playerTurn", options:[], context: playerTurnContext)
        gameEngine.addObserver(self, forKeyPath: "boardState", options:[.New, .Old], context: boardStateContext)
        gameEngine.addObserver(self, forKeyPath: "currentGameState", options:[.New], context: currentGameStateContext)
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

        if context == playerTurnContext {
            updateTurnLabel()
        } else if context == boardStateContext {
            if (gameEngine.currentGameState != GameState.Won &&
                gameEngine.currentGameState != GameState.Tied) {
                updateBoardForChanges(change)
            }

        } else if context == currentGameStateContext {
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
        let origViewPositions = viewPositions()
        let keys = origViewPositions.keys

        for key in keys{
            // get tag
            let tag:Int = key
            // get CGPoint
            let point = origViewPositions[key]!;
            // get view
            let view = self.view.viewWithTag(tag)!
            let snap = UISnapBehavior.init(item: view, snapToPoint: point)
            snap.damping = 0.9
            animator.addBehavior(snap)
            animator.updateItemUsingCurrentState(view)
        }
        gameEngine.restartGame()
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

    func viewPositions() -> Dictionary<Int, CGPoint> {
        var _viewPositions =  [Int: CGPoint]()

        for view in self.view.subviews {
            let tag = view.tag
            if tag == 0 {
                continue
            }
            _viewPositions[tag] = view.center
        }
        return _viewPositions
    }

    func showAlertGameOver {
        var title
        if gameEngine.currentGameState == GameState.won {
            title = // here we are

        } else if gameEngine.currentGameState == GameState.tied {

        }

    }


    func updateBoardForChanges(change: [String: AnyObject]?) { }
    func showAlertGameOver() {}

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

}