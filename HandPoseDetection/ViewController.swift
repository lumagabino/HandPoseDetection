//
//  ViewController.swift
//  HandEmoji
//
//  Created by Luma Gabino Vasconcelos on 26/06/20.
//  Copyright © 2020 Luma Gabino Vasconcelos. All rights reserved.
//

import UIKit
import Vision

@available(iOS 14.0, *)
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Escolhe uma imagem dos assets e cria uma imageView para ela
        guard let image = UIImage(named: "sample1") else { return }
        let imageView = UIImageView(image: image)
        
        //Ajuste das dimensões da imageView em relação a tela do device
        imageView.contentMode = .scaleAspectFit
        let scaledHeight = view.frame.width / image.size.width * image.size.height
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)
        
        //Adicioma a imageView na view da tela em questão
        self.view.addSubview(imageView)
        
        //Chama a função para a requisição da detecção de mãos
        self.handleHandPoseRequest(imageView: imageView, image: image)
    }
    
    func handleHandPoseRequest(imageView: UIImageView, image: UIImage) {
        //Passando a imagem como parâmetro para o ImageRequestHandler
        guard let cgImage =  image.cgImage else { return }
        
        //orientation: define a orientação da imagem e seta seu eixo corretamente
        //Ex: .up (para cima) o ponto (0,0) está encima e a esquerda
        //options: dicionário com opções que especificam informações auxiliares para o buffer/imagem
        //Ex: informações sobre a câmera caso seja usada
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        
        do {
            //Executa a requisição como uma detecção de posição das mãos
            let handPoseRequest = VNDetectHumanHandPoseRequest()
            try handler.perform([handPoseRequest])
            
            guard let observation = handPoseRequest.results?.first as? VNRecognizedPointsObservation else { return }
            
            //Dedo médio
            let middleFingerPoints = try observation.recognizedPoints(forGroupKey: .handLandmarkRegionKeyMiddleFinger)
            
            //Ponta do dedo médio
            guard let middleTipPoint = middleFingerPoints[.handLandmarkKeyMiddleTIP] else { return }
            
            //Verifica confiabilidade da informação
            if middleTipPoint.confidence > 0.3 {
                //Conversão para as dimensões da view
                let middleTip = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
                let x = (imageView.frame.width * middleTip.x)
                let y = (imageView.frame.height * middleTip.y)
                
                self.drawCricle(x: x, y: y)
            }
        } catch {
            print("Error")
        }
    }
    
    //Desenha um círculo com centro nas coordenadas x,y
    func drawCricle(x: CGFloat, y: CGFloat) {
        let circleView = UIView()
        circleView.backgroundColor = .red
        circleView.alpha = 0.4
        circleView.layer.cornerRadius = 25
        circleView.frame = CGRect(x: x-25, y: y-25, width: 50, height: 50) //25 é correção do raio do circulo que será desenhado na imagem
        self.view.addSubview(circleView)
    }
}

