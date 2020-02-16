package icespring.com.baidu.ime_boost;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterView;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

  FrameLayout flutterViewContainer1;
  FrameLayout flutterViewContainer2;

  Button pushContainer;
  Button changeContaner;
  Button pushCircle;


  FlutterView flutterView1;
  FlutterView flutterView2;

  boolean change = false;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.first);

    flutterViewContainer1 = findViewById(R.id.flutter_container1);
    flutterViewContainer2 = findViewById(R.id.flutter_container2);

    setupFlutterView();

    pushContainer = findViewById(R.id.pushSkinShop);
    pushCircle = findViewById(R.id.pushCircle);
    changeContaner = findViewById(R.id.changeContainer);
    pushContainer.setOnClickListener(this);
    changeContaner.setOnClickListener(this);
    pushCircle.setOnClickListener(this);

  }

  private void setupFlutterView() {
    BoostMethodCallHandler boostMethodCallHandler = new BoostMethodCallHandler();

    List<ImeCustomMethodCallHandler> list = new ArrayList<>();
    list.add(boostMethodCallHandler);
    ImeBoost.instance().init(getApplicationContext(), list);

    ImeBoost.instance().bindActivity(this, getLifecycle());

    flutterView1 = new FlutterView(this, FlutterView.RenderMode.texture);
    flutterView2 = new FlutterView(this, FlutterView.RenderMode.texture);

  }

  @Override
  protected void onResume() {
    super.onResume();
    flutterView1.attachToFlutterEngine(ImeBoost.instance().getFlutterEngine());
    flutterViewContainer1.addView(flutterView1);
    flutterViewContainer2.addView(flutterView2);
  }

  @Override
  public void onClick(View v) {
    switch (v.getId()) {
      case R.id.pushSkinShop:
        Map<String, String> param = new HashMap<>();
        param.put("pageName", "skin_shop");
        param.put("uniqueId", "testUniqueId");
        ImeBoost.instance().getBoostChannel().invokeMethod("pushContainer", param);
        break;
      case R.id.pushCircle:
        Map<String, String> param2 = new HashMap<>();
        param2.put("pageName", "circle");
        param2.put("uniqueId", "testUniqueId2");
        ImeBoost.instance().getBoostChannel().invokeMethod("pushContainer", param2);
        break;
      case R.id.changeContainer:
        if (!change) {
          flutterView1.detachFromFlutterEngine();
          flutterView2.attachToFlutterEngine(ImeBoost.instance().getFlutterEngine());
          change = !change;
        } else {
          flutterView2.detachFromFlutterEngine();
          flutterView1.attachToFlutterEngine(ImeBoost.instance().getFlutterEngine());
          change = !change;

        }

        break;
      default:
        break;
    }
  }
}
