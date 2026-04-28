using System.Collections.Generic;
using UnityEngine;

public enum Transitions
{
    StartToTreeFall,
    TreeFallToSeed,
    SeedEnd,
    RiverBegin,
    CaveEnter,
    CaveExit
};

public class MusicTransitions : MonoBehaviour
{
    [SerializeField] private MusicManager musicManager;
    [SerializeField] Transitions transition;

    void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            MakeTransition();
            GetComponent<BoxCollider>().enabled = false;
        }
    }

    public void MakeTransition()
    {
        switch (transition)
        {
            case Transitions.StartToTreeFall:
                StartCoroutine(musicManager.FadeTrack(SoundChannel.MusicMain, -80));

                break;
            case Transitions.TreeFallToSeed:
                musicManager.ChangeMainSourceClip(musicManager.audioClips[0]);
                musicManager.PlayStopClip(true, false);
                StartCoroutine(musicManager.FadeTrack(SoundChannel.MusicMain, 0));

                break;
            case Transitions.SeedEnd:
                StartCoroutine(musicManager.FadeTrack(SoundChannel.MusicMain, -80));

                break;
            case Transitions.RiverBegin:
                musicManager.ChangeMainSourceClip(musicManager.audioClips[1]);
                musicManager.PlayStopClip(true, true);
                StartCoroutine(musicManager.FadeTrack(SoundChannel.MusicMain, 0));

                // StartCoroutine(musicManager.FadeTrack(SoundChannel.RiverAmbiance, 0));
                StartCoroutine(musicManager.FadeTrack(SoundChannel.ForestAmbiance, -30));

                break;
            case Transitions.CaveEnter:
                StartCoroutine(musicManager.FadeTrack(SoundChannel.MusicMain, -80));
                StartCoroutine(musicManager.FadeTrack(SoundChannel.MusicCave, 0));

                StartCoroutine(musicManager.FadeTrack(SoundChannel.RiverAmbiance, -70));
                StartCoroutine(musicManager.FadeTrack(SoundChannel.CaveAmbiance, 0));

                break;
            case Transitions.CaveExit:
                StartCoroutine(musicManager.FadeTrack(SoundChannel.MusicCave, -80));
                StartCoroutine(musicManager.FadeTrack(SoundChannel.MusicMain, 0));

                StartCoroutine(musicManager.FadeTrack(SoundChannel.CaveAmbiance, -70));
                StartCoroutine(musicManager.FadeTrack(SoundChannel.RiverAmbiance, -20));

                break;
            default:
                break;
        }
    }
}
