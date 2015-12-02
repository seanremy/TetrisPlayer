//Authors: Sean Foley
//accesses a prolog theory for how to play tetris. This file mostly handles the screen input and key output
//
//Credit for Robot code goes to Alvin Alexander: http://alvinalexander.com/java/java-robot-class-example-mouse-keystroke
import java.awt.AWTException;
import java.awt.Dimension;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.event.InputEvent;
import java.awt.image.BufferedImage;
import java.io.FileInputStream;

import alice.tuprolog.Prolog;
import alice.tuprolog.SolveInfo;
import alice.tuprolog.Theory;

public class Control {
	static Robot robot;
	
	public static void main(String[] args) throws Exception {
		robot = new Robot();
		Control c = new Control();
		
		Prolog engine = new Prolog();
		Theory theory = new Theory(new FileInputStream("TetrisPlayer.pl"));
		engine.setTheory(theory);
		
		boolean gameLost = false;
		
		while(!gameLost) {
			Rectangle screen = new Rectangle(1920, 1080);
			BufferedImage screenImage = robot.createScreenCapture(screen);
			boolean[][] board = readScreen(screenImage);
			/*for (int i = 0; i < 17; i++) {
				for (int j = 0; j < 10; j++) {
					if (board[j][i])
						System.out.print("X");
					else
						System.out.print("O");
				}
				System.out.println();
			}*/
			while(isRemovingLine(board)) {
				robot.delay(50);
				screenImage = robot.createScreenCapture(screen);
				board = readScreen(screenImage);
			}
			String boardText = boardToString(board);
			//System.out.println(boardText);
			int tetrominoId = findTetrominoId(board);
			System.out.println("id: " + tetrominoId);
			SolveInfo info = engine.solve("findMove(" + boardText + ", " + tetrominoId + ", P, R).");
			SolveInfo resultInfo = info;
			if(!info.isSuccess()) {
				gameLost = true;
			}
			while (info.isSuccess()) {
				System.out.println("solution: " + info.getSolution() + " - bindings: " + info);
				if (engine.hasOpenAlternatives()) {
					info = engine.solveNext();
				} else {
					break;
				}
			}
			//execute move
			if(!gameLost) {
				int position = Character.getNumericValue(resultInfo.getBindingVars().get(0).toString().charAt(4));
				int rotation = Character.getNumericValue(resultInfo.getBindingVars().get(1).toString().charAt(4));
				executeMove(position, rotation, tetrominoId, c);
			}
			Rectangle score = new Rectangle(new Point(1422,200), new Dimension(400,30));
			BufferedImage scoreImage = robot.createScreenCapture(score);
			BufferedImage newScoreImage = scoreImage;
			//push tile down until score changes
			if(!gameLost) {
				robot.keyPress(83);
				while (compareImages(scoreImage, newScoreImage)) {
					scoreImage = newScoreImage;
					newScoreImage = robot.createScreenCapture(score);
				}
				robot.keyRelease(83);
			}
		}
	}
	
	public Control() throws AWTException {
		robot.setAutoDelay(200);
		robot.setAutoWaitForIdle(true);
		
		robot.delay(2500);
		robot.mouseMove(100, 100);
		robot.delay(500);
		
		leftClick();
		robot.delay(500);
		
		type("jkdkk");
	}
	
	private void leftClick() {
		robot.mousePress(InputEvent.BUTTON1_MASK);
		robot.delay(200);
		robot.mouseRelease(InputEvent.BUTTON1_MASK);
		robot.delay(200);
	}
	
	private void typeFast(String s) {
		if(s.length() == 0)
			return;
		byte[] bytes = s.getBytes();
	    for (byte b : bytes)
	    {
	      int code = b;
	      // keycode only handles [A-Z] (which is ASCII decimal [65-90])
	      if (code > 96 && code < 123) code = code - 32;
	      robot.delay(100);
	      robot.keyPress(code);
	      robot.keyRelease(code);
	    }
	}
	
	private void type(String s) {
		if(s.length() == 0)
			return;
		byte[] bytes = s.getBytes();
	    for (byte b : bytes)
	    {
	      int code = b;
	      // keycode only handles [A-Z] (which is ASCII decimal [65-90])
	      if (code > 96 && code < 123) code = code - 32;
	      robot.delay(300);
	      robot.keyPress(code);
	      robot.keyRelease(code);
	    }
	}
	
	private static boolean[][] readScreen(BufferedImage screen) {
		//tiles are about 78 pixels wide and 56 pixels tall
		//the bottom left tile pixel we want starts at 258, 1013
		boolean[][] ret = new boolean[10][17];
		for(int i = 0; i < 17; i++) {
			for(int j = 0; j < 10; j++) {
				//RGB of blank tile is -2033456
				ret[j][i] = screen.getRGB(258 + j * 96, 117 + i * 56) != -2033456 || screen.getRGB(238 + j * 96, 109 + i * 56) != -2033456; 
			}
		}
		return ret;
	}
	
	private static String boardToString(boolean[][] board) {
		String ret = "[";
		for(int i = 7; i < board[0].length; i++) {
			ret+="[";
			for(int j = 0; j < board.length; j++) {
				if(board[j][i])
					ret+="1,";
				else
					ret+="0,";
			}
			ret = ret.substring(0, ret.length() - 1); //to cut off the last comma
			ret+="],";
		}
		ret = ret.substring(0, ret.length() - 1); //to cut off the last comma
		ret+="]";
		return ret;
	}
	
	private static int findTetrominoId(boolean[][] board) {
		if(board[3][0] && board[4][0] && board[5][0] && board[6][0])
			return 1;
		else if(board[4][0] && board[5][0] && board[4][1] && board[5][1])
			return 2;
		else if(board[3][0] && board[4][0] && board[5][0] && board[4][1])
			return 3;
		else if(board[3][0] && board[4][0] && board[5][0] && board[5][1])
			return 4;
		else if(board[3][0] && board[4][0] && board[5][0] && board[3][1])
			return 5;
		else if(board[4][0] && board[5][0] && board[3][1] && board[4][1])
			return 6;
		else
			return 7;
	}
	
	public static boolean compareImages(BufferedImage imgA, BufferedImage imgB) {
		// The images must be the same size.
		if (imgA.getWidth() == imgB.getWidth() && imgA.getHeight() == imgB.getHeight()) {
			int width = imgA.getWidth();
			int height = imgA.getHeight();

			// Loop over every pixel.
			for (int y = 0; y < height; y++) {
				for (int x = 0; x < width; x++) {
					// Compare the pixels for equality.
					if (imgA.getRGB(x, y) != imgB.getRGB(x, y)) {
						return false;
					}
				}
			}
		} else {
			return false;
		}

		return true;
	}
	
	public static void executeMove(int position, int rotation, int tetrominoId, Control c) {
		System.out.println(position + " " + rotation);
		String posChange = "";
		String rotChange = "";
		int offset;
		if(tetrominoId != 2)
			offset = 3;
		else
			offset = 4;
		if (position < offset) {
			for (int i = 0; i < offset - position; i++) {
				posChange += "a";
			}
		} else if (position > offset) {
			for (int i = 0; i < position - offset; i++) {
				posChange += "d";
			}
		}
		if(rotation == 2)
			rotChange = "k";
		if(rotation == 3)
			rotChange = "kk";
		if(rotation == 4)
			rotChange = "m";
		
		System.out.println(posChange + " " + rotChange);
		
		//fixes line tile rotation thing
		if(tetrominoId == 1 && rotation % 2 == 0) {
			c.typeFast("a");
		}
		
		c.typeFast(posChange + rotChange);
		
		//fixes t tile rotation thing
		if(tetrominoId == 3 && rotation == 4) {
			c.typeFast("a");
		}
		
		//fixes j tile rotation thing
		if(tetrominoId == 4 && rotation == 4) {
			c.typeFast("a");
		}
		
		//push one extra time against wall to keep snug
		if(position == 0) {
			c.typeFast("a");
		}
		else if(position == 7 && ((tetrominoId == 3 && rotation % 2 == 1) || (tetrominoId == 4 && rotation % 2 == 1) || (tetrominoId == 5 && rotation % 2 == 1) || (tetrominoId == 6 && rotation % 2 == 1) || (tetrominoId == 7 && rotation % 2 == 1))) {
			c.typeFast("d");
		}
		else if(position == 8 && ((tetrominoId == 3 && rotation % 2 == 0) || (tetrominoId == 4 && rotation % 2 == 0) || (tetrominoId == 5 && rotation % 2 == 0) || (tetrominoId == 6 && rotation % 2 == 0) || (tetrominoId == 7 && rotation % 2 == 0))) {
			c.typeFast("d");
		}
		else if(position > 7 && tetrominoId == 1 && rotation % 2 == 0) {
			c.typeFast("d");
			if(position > 8)
				c.typeFast("d");				
		}
	}
	
	//returns whether or not the board is in the delayed state of removing a line
	public static boolean isRemovingLine(boolean[][] board) {
		for(int i = 0; i < board[0].length; i++) {
			if(board[0][i] && board[1][i]  && board[2][i]  && board[3][i]  && board[4][i]  && board[5][i]  && board[6][i]  && board[7][i]  && board[8][i]  && board[9][i])
				return true;
			robot.delay(50);
			if(board[0][i] && board[1][i]  && board[2][i]  && board[3][i]  && board[4][i]  && board[5][i]  && board[6][i]  && board[7][i]  && board[8][i]  && board[9][i])
				return true;
			robot.delay(25);
			if(board[0][i] && board[1][i]  && board[2][i]  && board[3][i]  && board[4][i]  && board[5][i]  && board[6][i]  && board[7][i]  && board[8][i]  && board[9][i])
				return true;
			robot.delay(12);
			if(board[0][i] && board[1][i]  && board[2][i]  && board[3][i]  && board[4][i]  && board[5][i]  && board[6][i]  && board[7][i]  && board[8][i]  && board[9][i])
				return true;
			robot.delay(12);
			if(board[0][i] && board[1][i]  && board[2][i]  && board[3][i]  && board[4][i]  && board[5][i]  && board[6][i]  && board[7][i]  && board[8][i]  && board[9][i])
				return true;
		}
		return false;
	}

}
