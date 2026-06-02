using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;

public class SoundSlider : MonoBehaviour
{
    public enum SliderType
    {
        Music,
        Ambiance,
        SFX
    }

    private Dictionary<SliderType, string> slidersDict = new Dictionary<SliderType, string>
    {
        [SliderType.Music] = "GeneralMusic",
        [SliderType.Ambiance] = "GeneralAmbiance",
        [SliderType.SFX] = "GeneralSFX"
    };

    public AudioMixer AudioMixer;
    [SerializeField] private SliderType sliderType;

    private void Start()
    {
        AudioMixer.GetFloat(slidersDict[sliderType], out float volume);
        GetComponent<Slider>().value = volume;
    }
    public void SetSliderVolume(float volume)
    {
        AudioMixer.SetFloat(slidersDict[sliderType], volume);
    }
}
