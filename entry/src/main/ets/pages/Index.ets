interface Brick {
  x: number;
  y: number;
  visible: boolean;
}

@Entry
@Component
struct Index {
  @State paddleX: number = 0;
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  private readonly paddleW: number = 100;
  private readonly paddleH: number = 16;

  @State ballX: number = 0;
  @State ballY: number = 0;
  private readonly ballSize: number = 12;
  private ballSpeedX: number = 3;
  private ballSpeedY: number = -3;
  private timer: number = 0;

  @State private bricks: Brick[] = [];
  private readonly brickW: number = 60;
  private readonly brickH: number = 20;
  private readonly brickPadding: number = 10;
  private readonly brickRows: number = 4;
  private readonly brickCols: number = 5;

  updateBall() {
    // 移动
    this.ballX += this.ballSpeedX;
    this.ballY += this.ballSpeedY;

    // 左右边界反弹
    if (this.ballX <= this.ballSize || this.ballX >= this.screenWidth - this.ballSize) {
      this.ballSpeedX = -this.ballSpeedX;
    }

    // 上边界反弹
    if (this.ballY <= this.ballSize) {
      this.ballSpeedY = -this.ballSpeedY;
    }

    // 挡板碰撞检测
    const paddleY = this.screenHeight - this.paddleH - 20;
    if (
      this.ballY + this.ballSize >= paddleY &&
        this.ballY - this.ballSize < paddleY &&
        this.ballX >= this.paddleX &&
        this.ballX <= this.paddleX + this.paddleW
    ) {
      this.ballSpeedY = -Math.abs(this.ballSpeedY);
    }

    // 掉出底部重置
    if (this.ballY > this.screenHeight) {
      this.ballX = this.screenWidth / 2;
      this.ballY = this.screenHeight - this.paddleH - 30;
    }
    this.checkBrickCollision();
  }

  build() {
    Stack() {
      // 黑色背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)

      // 白色挡板
      Row()
        .width(this.paddleW)
        .height(this.paddleH)
        .backgroundColor(Color.White)
        .position({ left: this.paddleX, bottom: 20 })

      Circle()
        .width(this.ballSize * 2)
        .height(this.ballSize * 2)
        .fill(Color.White)
        .position({
          left: this.ballX - this.ballSize,
          top: this.ballY - this.ballSize
        })
      ForEach(this.bricks, (item: Brick) => {
        if (item.visible) {
          Row()
            .width(this.brickW)
            .height(this.brickH)
            .backgroundColor(Color.Red)
            .position({ left: item.x, top: item.y })
        }
      }, (item: Brick) => item.x + ',' + item.y)
    }
    .width('100%')
    .height('100%')
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Move) {
        const maxX = this.screenWidth - this.paddleW;
        this.paddleX = Math.max(0, Math.min(
          event.touches[0].x - this.paddleW / 2,
          maxX
        ));
      }
    })
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      this.screenWidth = Number(newArea.width);
      this.screenHeight = Number(newArea.height);
      this.paddleX = (this.screenWidth - this.paddleW) / 2;

      this.ballX = this.screenWidth / 2;
      this.ballY = this.screenHeight - this.paddleH - 30;

      // 直接在这里初始化砖块
      this.bricks = [];
      for (let row = 0; row < this.brickRows; row++) {
        for (let col = 0; col < this.brickCols; col++) {
          this.bricks.push({
            x: col * (this.brickW + this.brickPadding) + 20,
            y: row * (this.brickH + this.brickPadding) + 50,
            visible: true
          });
        }
      }
    })
    .onAppear(() => {
      // 启动游戏循环
      this.timer = setInterval(() => {
        this.updateBall();
      }, 16);
    })
    .onDisAppear(() => {
      clearInterval(this.timer);
    })
  }

  // 碰撞检测
  checkBrickCollision() {
    for (let i = 0; i < this.bricks.length; i++) {
      const brick = this.bricks[i];
      if (!brick.visible) continue;

      if (
        this.ballX + this.ballSize > brick.x &&
          this.ballX - this.ballSize < brick.x + this.brickW &&
          this.ballY + this.ballSize > brick.y &&
          this.ballY - this.ballSize < brick.y + this.brickH
      ) {
        // 直接从数组里删掉这个砖块！画面一定会消失！
        this.bricks.splice(i, 1);
        this.ballSpeedY = -this.ballSpeedY;
        break;
      }
    }
  }

}
