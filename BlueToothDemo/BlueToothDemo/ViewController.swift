//
//  ViewController.swift
//  BlueToothDemo
//
//  Created by YuXiang on 2017/6/14.
//  Copyright © 2017年 Rookie.YXiang. All rights reserved.
//

import UIKit
import CoreBluetooth

//fileprivate let deviceName:String = "null"
fileprivate let screenW:CGFloat = UIScreen.main.bounds.size.width
fileprivate let screenH:CGFloat = UIScreen.main.bounds.size.height
fileprivate let cellID:String = "CELL"

class ViewController: UIViewController {

    /// 中心管理者
    var cMgr:CBCentralManager!

    /// 连接到的外设
    var peripheral:CBPeripheral!
    
    var writeCharacteristic:CBCharacteristic!
    
    var lable:UILabel!
    
    var tableV:UITableView!
    
    var getbytes :[UInt8]    = [0x93, 0x8e, 0x04, 0x00, 0x08, 0x04, 0x10]
    /// 存储设备名
    var deviceDataList:NSMutableArray = NSMutableArray()
    
    /// 存储外设信息
    var deviceInfo:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cMgr = CBCentralManager()
        cMgr.delegate = self as CBCentralManagerDelegate
        
        let start:UIButton = UIButton(type: .custom)
        start.backgroundColor = UIColor.blue
        start.frame = CGRect(x: 80, y: 80, width: 100, height: 35)
        start.setTitle("打开", for: UIControlState.normal)
        start.addTarget(self, action: #selector(didClickedStartButton(_:)), for: .touchUpInside)
        start.tag = 10
        self.view.addSubview(start)
        
        let start1:UIButton = UIButton(type: .custom)
        start1.backgroundColor = UIColor.red
        start1.frame = CGRect(x: 80, y: 150, width: 160, height: 35)
        start1.setTitle("发送读取数据指令", for: UIControlState.normal)
        start1.addTarget(self, action: #selector(didClickedStartButton(_:)), for: .touchUpInside)
        start1.tag = 20
        self.view.addSubview(start1)
        
        let rect = CGRect(x: 10, y: 220, width: 280, height: 30)
        let lable = UILabel(frame: rect)
        lable.text = "无数据"
        let font = UIFont(name: "宋体",size: 12)
        lable.font = font
        lable.shadowColor = UIColor.lightGray
        lable.shadowOffset = CGSize(width: 2,height: 2)
        lable.textAlignment = NSTextAlignment.center
        lable.textColor = UIColor.purple
        lable.backgroundColor = UIColor.yellow
        self.lable = lable
        self.view.addSubview(lable)
        
        let tableVRect = CGRect(x: 0, y: 0, width:screenW, height: screenH)
        let tableView:UITableView = UITableView(frame: tableVRect, style: UITableViewStyle.plain)
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self as UITableViewDataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.tableV = tableView;
        self.view.addSubview(tableView)
        tableView.isHidden = true
    }
    
    @objc fileprivate func didClickedStartButton(_ btn:UIButton) {
        switch  btn.tag{
        case 10:
            print("扫描设备中.....")
            
            guard self.cMgr.state == .poweredOn else {
                customAlertView("温馨提示", message: "请滑动手机打开设备")
                return
            }
            cMgr.scanForPeripherals(withServices: nil, options: nil)
            self.tableV.isHidden = false;
        case 20:
            print("发送数据中.....")
            //向设备发送指令
            writeToPeripheral(getbytes)
        default:
            break;
        }
   }
    
    fileprivate func writeToPeripheral(_ bytes:[UInt8]) {
        if writeCharacteristic != nil {
            let data1:Data = dataWithHexstring(bytes)
            
            self.peripheral.writeValue(data1, for: writeCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    /**
     将[UInt8]数组转换为NSData
     
     - parameter bytes: <#bytes description#>
     
     - returns: <#return value description#>
     */
    
   fileprivate func dataWithHexstring(_ bytes:[UInt8]) -> Data {
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        return data
    }
    
    fileprivate  func customAlertView(_ title:String , message:String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action: UIAlertAction) -> Void in
            /**
             写取消后操作
             */
        })
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            /**
             写确定后操作
             */
        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
}

extension ViewController:CBCentralManagerDelegate {

    // MARK : - CBCentralManagerDelegate
    /// 蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("未知")
        case .resetting:
            print("重置")
        case .unsupported:
            print("不支持的")
        case .poweredOn:
            print("蓝牙打开")
        case .unauthorized:
            print("未经授权的")
        case .poweredOff:
            print("蓝牙关闭")
  
        }
    }
    
 
     /// 发现外设
     ///
     /// - Parameters:
     ///   - central: 中心管理者
     ///   - peripheral: 外设
     ///   - advertisementData: 外设携带的数据
     ///   - RSSI: 外设发出的蓝牙信号强度
     func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        print("<----发现设备-----> 搜索到外设是:\(peripheral)\n外设携带的数据:\(advertisementData)\n外设信号强度 \(RSSI)")
        self.cMgr = central
    
        self.deviceDataList.add(peripheral.name ?? "")
        self.deviceInfo.add(peripheral)
        self.tableV.reloadData()
    }
    
    /// 设备连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("----连接成功 ----> 中心管理者 :\(central) -- 外设 :\(String(describing: peripheral.name))")
        
        guard peripheral.name == self.peripheral.name else {
             customAlertView( "温馨提示", message: "设备不是名字为\(String(describing: self.peripheral.name))")
            return;
        }
    
        customAlertView( "温馨提示", message: "设备\(String(describing: peripheral.name))连接成功")
        self.cMgr.stopScan() // 关闭扫描
        self.peripheral.delegate = self as? CBPeripheralDelegate
        // 外设发现服务,传nil代表不过滤
        //这里会触发外设的代理方法 func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
        self.peripheral.discoverServices(nil)
    }
    
    /// 设备连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("设备连接失败")
        customAlertView( "温馨提示", message: "设备\(String(describing: self.peripheral.name))连接失败")
    }
    
    /// 将要恢复状态
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("将要恢复状态")
    }
    
    /// 丢失连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("丢失连接")
        customAlertView( "温馨提示", message: "\(String(describing: peripheral.name))设备丢失连接")
    }
    
    // MARK : - CBPeripheralDelegate
    /// 发现服务调用次方法
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("发现服务调用次方法---->外设: \(peripheral) error: \(String(describing: error))")
        for s:CBService in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: s)
            print("外设服务的UUID\(s.uuid.uuidString)")
        }
    }
    
    /// 获得外围设备的服务,服务的特征
    /// 发现外设服务里的特征的时候调用的代理方法(这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
         print("----获得外围设备的服务,服务的特征------")
        for  c:CBCharacteristic in service.characteristics! {
            print(c.uuid.uuidString)
            peripheral.setNotifyValue(true, for: c)
        }
    }
    
    /// 写入后的回掉方法
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
         print("----发现特征------")
        
    }
    
    
    /// 外设状态更新通知
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("------  didUpdateNotificationStateFor")
        if error != nil {
            print("\(String(describing: error?.localizedDescription))")
        }
        print(characteristic)
    }
    
    /// 获取外设的数据
    /// 更新特征的value的时候会调用 （凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法） 你可以判断是否
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor-----\(characteristic)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        
    }
    
}

extension ViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceDataList.count != 0  ? self.deviceDataList.count : 1;
    }
}

extension ViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.deviceDataList.count != 0 else {
            cell.textLabel?.text = "扫描中...."
            return
        }
        cell.textLabel?.text = self.deviceDataList[indexPath.row] as? String
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableV.isHidden = true
        
        self.peripheral = self.deviceInfo[indexPath.row] as! CBPeripheral
        // 连接
        self.cMgr.connect(self.peripheral, options: nil)
    }
}



