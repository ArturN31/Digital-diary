// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "jquery"
import "jquery_ujs"
import "jquery-ui-rails"

import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
import "controllers"

//= require jquery3
//= require jquery_ujs
//= require jquery-ui-rails
//= require_tree .

var clicked = true
$(document).ready(function(){
    //used to hide/show the barcode scanner on button click
    $("#camera").on("click tap", function() {
        if(clicked == true) {
            $("#barcode-scanner").show(); //showing the barcode scanner div
            
            load_quagga();

            $([document.documentElement, document.body]).animate({
                scrollTop: $("#barcode-scanner").offset().top
            }, 500);
            
        } else {
            $("#barcode-scanner").hide(); //hiding the barcode scanner div
            Quagga.stop();
            clicked = true
        }
    });
});

//Displays confirm dialog that manages UPC verification
function ConfirmDialog(message, code) {
    $('<div id="UPC-dialog"></div>').appendTo('body')
    .html('<div class="text-center"><h6>' + message + '</h6></div>')
    .dialog({
        modal: true,
        zIndex: 10000,
        autoOpen: true,
        resizable: false,
        dialogClass: "text-center",
        close: function() {
            $("#barcode-scanner video").hide();
            Quagga.stop();
        },
        buttons: {
            //Setting up yes button
            "Yes": {
                text: "Correct",
                id: "btn-dialog",
                //If yes button clicked
                click: function() {
                    $("#barcode-scanner").hide(); //hiding the barcode scanner div
                    $("#entry_food_upc_code").val(code); //adding UPC to the form field
                    
                    $(this).dialog("close"); //closing dialog
                }
            },
            //Setting up no button
            "No": {
                text: "Rescan",
                id: "btn-dialog",
                //If no button clicked
                click: function() {
                    $(this).dialog("close"); //closing dialog
                    load_quagga(); //loading barcode scanner
                }
            }
        },
        position: { my: "center", at: "bottom" }
    });
};

function load_quagga(){
    clicked = false
    //if barcode element is present && user has access to media devices && of type getUserMedia
    if ($('#barcode-scanner').length > 0 
    && navigator.mediaDevices 
    && typeof navigator.mediaDevices.getUserMedia === 'function') {
        $("#barcode-scanner video").show();

        var last_result = [];
        if (Quagga.initialized == undefined) {
            Quagga.onDetected(function(result) {
                var last_code = result.codeResult.code; //scanned code
                ConfirmDialog("<br><span style='font-size: larger;'>Code:<br>" + last_code + "</span><br><br>Please, verify the code.<br><br>", last_code); //Passing message and last_code to the ConfirmDialog function
                Quagga.stop();
            });
        }

        //initializing quagga
        Quagga.init({
            //setting input stream
            inputStream : {
                name : "Live",
                type : "LiveStream",
                numOfWorkers: navigator.hardwareConcurrency,
                target: document.querySelector('#barcode-scanner')  
            },
            //setting decoders
            decoder: {
                //identified formats: ean_13 
                readers : ['ean_reader','upc_reader']
            }
        },function(err) {
            //if error return error
            if (err) { console.log(err); return }
            //else run quagga
            Quagga.initialized = true;
            Quagga.start();
        });
    }
    else {
        alert("media not working")
    }
};
