#include "chunk.hpp"
#include "game.hpp"
#include "camera.hpp"
#include "chunkindex.hpp"

#include <vector>
#include <bitset>

extern Camera g_cam;

class GameScene {
public:
  virtual void                  PrepareSpriteListForRender() = 0;
  virtual void                  PreRender()  = 0;
  virtual std::vector<Sprite*>* GetSpriteListForRender() = 0;
  virtual void                  PostRender() = 0;
  virtual void                  RenderHUD() = 0;
  virtual void                  Update(float) = 0;
  virtual void                  OnKeyPressed(char key) { };
  virtual void                  OnKeyReleased(char key) { };
  
  Camera* camera;
  
  GameScene() : camera(&g_cam) { }
};

class TestShapesScene : public GameScene {
public:
  Sprite* test_sprite;
  ChunkSprite* global_xyz;
  void PreRender() { }
  void PostRender() { }
  std::vector<Sprite*> sprite_render_list;
  void PrepareSpriteListForRender();
  std::vector<Sprite*>* GetSpriteListForRender();
  void Update(float secs) { };
  void RenderHUD() { };
};

class ClimbScene : public GameScene {
public:
  
  class Platform {
  public:
    Sprite* sprite;
    virtual Sprite* GetSpriteForDisplay() = 0;
    virtual Sprite* GetSpriteForCollision() = 0;
    virtual glm::vec3 GetOriginalPos() = 0;
    virtual void    Update(float) { }
    ~Platform() { delete sprite; }
  };
  
  class NormalPlatform : public Platform {
  public:
    NormalPlatform(Sprite* _s) {
      sprite = _s;
    }
    Sprite* GetSpriteForDisplay() { return sprite; }
    Sprite* GetSpriteForCollision() { return sprite; }
    glm::vec3 GetOriginalPos() { return sprite->pos; }
  };
  
  class DamagablePlatform : public Platform {
  public:
    bool damaged;
    DamagablePlatform(Sprite* _s) {
      sprite = _s;
      
      // 复制体素信息
      ChunkSprite* cs = (ChunkSprite*)(sprite);
      ChunkGrid* g = (ChunkGrid*)(cs->chunk);
      cs->chunk = new ChunkGrid(*g);
      
      damaged = false;
    }
    Sprite* GetSpriteForDisplay() { return sprite; }
    Sprite* GetSpriteForCollision() { return sprite; }
    glm::vec3 GetOriginalPos() { return sprite->pos; }
    void DoDamage(const glm::vec3& world_x);
  };
  
  class ExitPlatform : public Platform {
  public:
    enum State {
      Hidden,
      FlyingIn,
      Visible
    };
    State state;
    static int FLY_IN_DURATION;
    int fly_in_end_millis;
    ExitPlatform(Sprite* _s) {
      sprite = _s;
      state = Hidden;
      fly_in_end_millis = 0;
    }
    Sprite* GetSpriteForDisplay() {
      if (state != Hidden) return sprite;
      else return nullptr;
    }
    void Update(float secs);
    Sprite* GetSpriteForCollision() { 
      if (state != Visible) return nullptr;
      else return sprite;
    }
    glm::vec3 GetOriginalPos() { return sprite->pos; }
    void FlyIn();
  };
  
  //
  static ClimbScene* instance;
  
  // 模型
  static std::vector<ChunkGrid*> model_platforms;
  static std::vector<ChunkGrid*> model_backgrounds;
  static ChunkGrid* model_exit;
  static ChunkGrid* model_char;
  static ChunkGrid* unit_sq;
  static ChunkGrid* model_anchor;
  static ChunkGrid* model_coin;
  
  Sprite* player, *player_disp;
  float player_x_thrust;
  int   anchor_levels; // 按键层数
  bool is_debug;
  glm::vec3 debug_vel;
  ChunkSprite* anchor;
  glm::vec3 anchor_rope_endpoint;
  
  std::vector<Platform*> platforms;
  AABB cam_aabb;
  std::vector<Sprite*> rope_segments;
  std::vector<ChunkSprite*> backgrounds0, backgrounds1;
  
  std::vector<Sprite*> coins, initial_coins;
  int num_coins, num_coins_total;
  int curr_level;
  float curr_level_time;
  
  static void InitStatic();
  
  static const float SPRING_K; // 弹力系数
  static const float L0      ; // 绳子的初始长度
  static const float GRAVITY;  // 重力加速度
  static const float X_THRUST; // 荡秋千带来的横向加速度
  static const int   NUM_SEGMENTS; // 画的时候有几段
  static const float PROBE_DIST; // 探出的距离
  static const int   PROBE_DURATION; // 探出时所用时间
  static const float ANCHOR_LEN; // 锚的长度  [-----绳子---------]-[--锚--> ]
  static const float PLAYER_DISP_DELTAZ; // 显示玩家时的Z平移量
  static const float X_VEL_DAMP;
  static const float Y_VEL_DAMP;
  static const glm::vec3 RELEASE_THRUST; // 松开绳子时给的向上的冲击
  
  static const float CAM_FOLLOW_DAMP; // 视角跟随的阻尼系数
  static const float BACKGROUND_SCALE; // 背景放大倍数
  
  static const int   COUNTDOWN_MILLIS;        // 开始游戏之前的倒计时
  static const int   LEVEL_FINISH_SEQ_MILLIS; // 关卡完成序列的倒计时
  static const int   LEVEL_FINISH_JUMP_PERIOD;
  
  std::bitset<10> keyflags;
  
  bool is_key_pressed;
  
  enum RopeState {
    Hidden, Probing, Anchored, Retracting
  };
  RopeState rope_state;
  glm::vec3 probe_delta;
  
  unsigned probe_end_millis;
  
  enum ClimbGameState {
    ClimbGameStateInGame,
    ClimbGameStateStartCountdown,
    ClimbGameStateLevelFinishSequence,
    ClimbGameStateLevelEndWaitKey,
  };
  
  // 这个结构控制游戏状态从 ClimbGameStateLevelFinishSequene 到
  //                   ClimbGameStateLevelEndWaitKey 之间的过程。
  struct LevelFinishState {
    // for level finish
    ClimbScene* parent; // singleton
    glm::vec3 pos0, pos1;
    float GetCompletion() {
      return 1.0f - (1.0f * parent->countdown_millis / LEVEL_FINISH_SEQ_MILLIS);
    }
  };
  ClimbGameState game_state;
  float countdown_millis;
  LevelFinishState level_finish_state;
  int is_all_rockets_collected;
  
  ClimbScene();
  void Init();
  void PreRender();
  void PostRender() { }
  std::vector<Sprite*> sprite_render_list;
  void PrepareSpriteListForRender();
  std::vector<Sprite*>* GetSpriteListForRender();
  void Update(float secs);
  void RenderHUD();
  virtual void OnKeyPressed(char);
  virtual void OnKeyReleased(char);
  void SetAnchorPoint(glm::vec3 anchor_p, glm::vec3 anchor_dir);
  
  // 每帧更新时做的事情
  void RotateCoins(float secs);
  void CameraFollow(float secs);
  void LayoutBackground();
  void HideRope();
  
  glm::vec3 GetPlayerInitPos();
  glm::vec3 GetPlayerInitVel();
  glm::vec3 GetPlayerEffectivePos();
  void SpawnPlayer();
  
  void StartLevel(int levelid);
  void ComputeCamBB(); // Cam Bounding Box
  void SetBackground(int bgid);
  void SetGameState(ClimbGameState gs);
  void RevealExit();
  void LayoutRocketsOnExit(const glm::vec3& exit_pos);
  void BeginLevelCompleteSequence();
};